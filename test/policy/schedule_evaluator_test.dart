import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static DayOfWeek fromString(String s) => switch (s) {
    'MONDAY' => DayOfWeek.monday,
    'TUESDAY' => DayOfWeek.tuesday,
    'WEDNESDAY' => DayOfWeek.wednesday,
    'THURSDAY' => DayOfWeek.thursday,
    'FRIDAY' => DayOfWeek.friday,
    'SATURDAY' => DayOfWeek.saturday,
    'SUNDAY' => DayOfWeek.sunday,
    _ => throw ArgumentError('Unknown day: $s'),
  };

  DayOfWeek get previous =>
      DayOfWeek.values[(index - 1) % DayOfWeek.values.length];
}

class TimeOfDay {
  const TimeOfDay(this.hour, this.minute);
  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  bool operator >=(TimeOfDay other) => totalMinutes >= other.totalMinutes;
  bool operator <(TimeOfDay other) => totalMinutes < other.totalMinutes;
}

class Schedule {
  const Schedule({
    required this.startTime,
    required this.endTime,
    required this.days,
  });
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Set<DayOfWeek> days;
}

bool isScheduleActive({
  required Schedule schedule,
  required DayOfWeek dayOfWeek,
  required TimeOfDay localTime,
}) {
  final isOvernight = schedule.startTime >= schedule.endTime;

  if (isOvernight) {
    if (localTime >= schedule.startTime && schedule.days.contains(dayOfWeek)) {
      return true;
    }
    final previousDay = dayOfWeek.previous;
    if (localTime < schedule.endTime && schedule.days.contains(previousDay)) {
      return true;
    }
    return false;
  } else {
    if (!schedule.days.contains(dayOfWeek)) return false;
    return localTime >= schedule.startTime && localTime < schedule.endTime;
  }
}

void main() {
  group('schedule evaluator — shared test vectors', () {
    test('overnight_weekdays.json round-trip', () {
      final file = File('test_vectors/schedules/overnight_weekdays.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final scheduleJson = json['schedule'] as Map<String, dynamic>;

      final schedule = Schedule(
        startTime: TimeOfDay(
          scheduleJson['startHour'] as int,
          scheduleJson['startMinute'] as int,
        ),
        endTime: TimeOfDay(
          scheduleJson['endHour'] as int,
          scheduleJson['endMinute'] as int,
        ),
        days: (scheduleJson['days'] as List)
            .map((d) => DayOfWeek.fromString(d as String))
            .toSet(),
      );

      final cases = json['cases'] as List;
      for (final c in cases) {
        final caseMap = c as Map<String, dynamic>;
        final dayOfWeek = DayOfWeek.fromString(caseMap['dayOfWeek'] as String);
        final timeParts = (caseMap['localDateTime'] as String)
            .split('T')[1]
            .split(':');
        final localTime = TimeOfDay(
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        final expected = caseMap['expected'] as bool;
        final description = caseMap['description'] as String;

        expect(
          isScheduleActive(
            schedule: schedule,
            dayOfWeek: dayOfWeek,
            localTime: localTime,
          ),
          expected,
          reason: description,
        );
      }
    });
  });
}
