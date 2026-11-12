import 'package:blocker/policy/approval.dart';
import 'package:blocker/policy/change_direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requiresApproval', () {
    test('stricter change never needs approval', () {
      expect(
        requiresApproval(change: SettingsChangeKind.addApp, strictModeOn: true),
        isFalse,
      );
    });

    test('stricter change with strict mode off needs no approval', () {
      expect(
        requiresApproval(
          change: SettingsChangeKind.addSchedule,
          strictModeOn: false,
        ),
        isFalse,
      );
    });

    test('weaker change with strict mode off needs no approval', () {
      expect(
        requiresApproval(
          change: SettingsChangeKind.removeApp,
          strictModeOn: false,
        ),
        isFalse,
      );
    });

    test('weaker change with strict mode on needs approval', () {
      expect(
        requiresApproval(
          change: SettingsChangeKind.removeApp,
          strictModeOn: true,
        ),
        isTrue,
      );
    });

    test('disabling strict mode needs approval when strict mode is on', () {
      expect(
        requiresApproval(
          change: SettingsChangeKind.disableStrictMode,
          strictModeOn: true,
        ),
        isTrue,
      );
    });

    test('every weaker change needs approval when strict mode is on', () {
      const weakerChanges = [
        SettingsChangeKind.removeApp,
        SettingsChangeKind.removeWebsite,
        SettingsChangeKind.removeSchedule,
        SettingsChangeKind.raiseLimit,
        SettingsChangeKind.disableStrictMode,
      ];
      for (final change in weakerChanges) {
        expect(
          requiresApproval(change: change, strictModeOn: true),
          isTrue,
          reason: '$change should require approval when strict mode is on',
        );
      }
    });

    test(
      'no stricter change ever needs approval regardless of strict mode',
      () {
        const stricterChanges = [
          SettingsChangeKind.addApp,
          SettingsChangeKind.addWebsite,
          SettingsChangeKind.addSchedule,
          SettingsChangeKind.lowerLimit,
          SettingsChangeKind.enableStrictMode,
        ];
        for (final change in stricterChanges) {
          expect(
            requiresApproval(change: change, strictModeOn: true),
            isFalse,
            reason: '$change should not require approval',
          );
          expect(
            requiresApproval(change: change, strictModeOn: false),
            isFalse,
            reason: '$change should not require approval',
          );
        }
      },
    );
  });

  group('ApprovalGate', () {
    test('each approval covers exactly one change', () {
      final gate = ApprovalGate();
      gate.grantApproval();
      expect(gate.hasUnusedApproval, isTrue);
      gate.useApproval();
      expect(gate.hasUnusedApproval, isFalse);
    });

    test('after approval is used the next weaker change needs a new one', () {
      final gate = ApprovalGate();
      gate.grantApproval();
      gate.useApproval();
      expect(gate.hasUnusedApproval, isFalse);
    });

    test('cannot use approval when none is granted', () {
      final gate = ApprovalGate();
      expect(gate.hasUnusedApproval, isFalse);
      expect(gate.useApproval, throwsStateError);
    });

    test('granting a second approval before using the first replaces it', () {
      final gate = ApprovalGate();
      gate.grantApproval();
      gate.grantApproval();
      expect(gate.hasUnusedApproval, isTrue);
      gate.useApproval();
      expect(gate.hasUnusedApproval, isFalse);
    });
  });
}
