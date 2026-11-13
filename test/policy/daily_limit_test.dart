import 'dart:convert';
import 'dart:io';

import 'package:blocker/policy/daily_limit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateDailyLimit', () {
    test('30-minute limit: after 30 minutes, isBlocked is true', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 30),
        usedToday: const Duration(minutes: 30),
      );
      expect(result.isBlocked, isTrue);
      expect(result.remaining, Duration.zero);
    });

    test('30-minute limit: at 29 minutes, not blocked', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 30),
        usedToday: const Duration(minutes: 29),
      );
      expect(result.isBlocked, isFalse);
      expect(result.remaining, const Duration(minutes: 1));
    });

    test('5-minute warning fires when 25 of 30 minutes used', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 30),
        usedToday: const Duration(minutes: 25),
      );
      expect(result.isBlocked, isFalse);
      expect(result.shouldWarn, isTrue);
      expect(result.remaining, const Duration(minutes: 5));
    });

    test('no warning at 24 minutes used (6 minutes left)', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 30),
        usedToday: const Duration(minutes: 24),
      );
      expect(result.shouldWarn, isFalse);
    });

    test('warning does not fire when already blocked', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 30),
        usedToday: const Duration(minutes: 31),
      );
      expect(result.isBlocked, isTrue);
      expect(result.shouldWarn, isFalse);
    });

    test('zero usage is not blocked', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 30),
        usedToday: Duration.zero,
      );
      expect(result.isBlocked, isFalse);
      expect(result.remaining, const Duration(minutes: 30));
    });

    test('minimum allowance of 5 minutes', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 5),
        usedToday: const Duration(minutes: 5),
      );
      expect(result.isBlocked, isTrue);
    });

    test('5-minute allowance warns from the start', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(minutes: 5),
        usedToday: Duration.zero,
      );
      expect(result.shouldWarn, isTrue);
    });

    test('maximum allowance of 8 hours', () {
      final result = evaluateDailyLimit(
        allowance: const Duration(hours: 8),
        usedToday: const Duration(hours: 7, minutes: 55),
      );
      expect(result.isBlocked, isFalse);
      expect(result.shouldWarn, isTrue);
    });
  });

  group('clampAllowance', () {
    test('returns minimum for values below 5 minutes', () {
      expect(
        clampAllowance(const Duration(minutes: 2)),
        const Duration(minutes: 5),
      );
    });

    test('returns maximum for values above 8 hours', () {
      expect(
        clampAllowance(const Duration(hours: 10)),
        const Duration(hours: 8),
      );
    });

    test('returns value unchanged when within range', () {
      expect(
        clampAllowance(const Duration(hours: 1)),
        const Duration(hours: 1),
      );
    });

    test('returns 5 minutes unchanged at lower boundary', () {
      expect(
        clampAllowance(const Duration(minutes: 5)),
        const Duration(minutes: 5),
      );
    });

    test('returns 8 hours unchanged at upper boundary', () {
      expect(
        clampAllowance(const Duration(hours: 8)),
        const Duration(hours: 8),
      );
    });
  });

  group('shouldResetUsage', () {
    test('resets when date changes', () {
      expect(
        shouldResetUsage(
          lastResetDate: DateTime(2026, 11, 12),
          currentDate: DateTime(2026, 11, 13),
        ),
        isTrue,
      );
    });

    test('does not reset on same date', () {
      expect(
        shouldResetUsage(
          lastResetDate: DateTime(2026, 11, 12),
          currentDate: DateTime(2026, 11, 12),
        ),
        isFalse,
      );
    });

    test('resets across month boundary', () {
      expect(
        shouldResetUsage(
          lastResetDate: DateTime(2026, 10, 31),
          currentDate: DateTime(2026, 11, 1),
        ),
        isTrue,
      );
    });

    test('resets across year boundary', () {
      expect(
        shouldResetUsage(
          lastResetDate: DateTime(2026, 12, 31),
          currentDate: DateTime(2027, 1, 1),
        ),
        isTrue,
      );
    });
  });

  group('shared test vectors', () {
    test('daily_limit.json round-trip', () {
      final file = File('test_vectors/limits/daily_limit.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final cases = json['cases'] as List;

      for (final c in cases) {
        final caseMap = c as Map<String, dynamic>;
        final allowance = Duration(minutes: caseMap['allowanceMinutes'] as int);
        final usedToday = Duration(seconds: caseMap['usedSeconds'] as int);
        final expectedBlocked = caseMap['expectedBlocked'] as bool;
        final expectedWarning = caseMap['expectedWarning'] as bool;
        final expectedRemainingSeconds =
            caseMap['expectedRemainingSeconds'] as int;
        final description = caseMap['description'] as String;

        final result = evaluateDailyLimit(
          allowance: allowance,
          usedToday: usedToday,
        );

        expect(
          result.isBlocked,
          expectedBlocked,
          reason: '$description (isBlocked)',
        );
        expect(
          result.shouldWarn,
          expectedWarning,
          reason: '$description (shouldWarn)',
        );
        expect(
          result.remaining.inSeconds,
          expectedRemainingSeconds,
          reason: '$description (remaining)',
        );
      }
    });
  });
}
