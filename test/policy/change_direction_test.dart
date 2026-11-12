import 'package:blocker/policy/change_direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyChange', () {
    test('adding an app to the blocklist is stricter', () {
      expect(
        classifyChange(SettingsChangeKind.addApp),
        ChangeDirection.stricter,
      );
    });

    test('removing an app from the blocklist is weaker', () {
      expect(
        classifyChange(SettingsChangeKind.removeApp),
        ChangeDirection.weaker,
      );
    });

    test('adding a schedule is stricter', () {
      expect(
        classifyChange(SettingsChangeKind.addSchedule),
        ChangeDirection.stricter,
      );
    });

    test('deleting a schedule is weaker', () {
      expect(
        classifyChange(SettingsChangeKind.removeSchedule),
        ChangeDirection.weaker,
      );
    });

    test('lowering a daily limit is stricter', () {
      expect(
        classifyChange(SettingsChangeKind.lowerLimit),
        ChangeDirection.stricter,
      );
    });

    test('raising a daily limit is weaker', () {
      expect(
        classifyChange(SettingsChangeKind.raiseLimit),
        ChangeDirection.weaker,
      );
    });

    test('turning strict mode on is stricter', () {
      expect(
        classifyChange(SettingsChangeKind.enableStrictMode),
        ChangeDirection.stricter,
      );
    });

    test('turning strict mode off is weaker', () {
      expect(
        classifyChange(SettingsChangeKind.disableStrictMode),
        ChangeDirection.weaker,
      );
    });

    test('adding a website is stricter', () {
      expect(
        classifyChange(SettingsChangeKind.addWebsite),
        ChangeDirection.stricter,
      );
    });

    test('removing a website is weaker', () {
      expect(
        classifyChange(SettingsChangeKind.removeWebsite),
        ChangeDirection.weaker,
      );
    });
  });

  group('SettingsChangeKind exhaustiveness', () {
    test('every kind maps to a direction', () {
      for (final kind in SettingsChangeKind.values) {
        expect(classifyChange(kind), isA<ChangeDirection>());
      }
    });
  });
}
