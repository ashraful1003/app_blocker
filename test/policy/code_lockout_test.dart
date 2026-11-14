import 'package:blocker/policy/code_lockout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeLockout', () {
    test('is not locked out before any wrong attempts', () {
      final lockout = CodeLockout();
      expect(lockout.isLockedOut(Duration.zero), isFalse);
    });

    test('4 wrong attempts do not trigger lockout', () {
      final lockout = CodeLockout();
      for (var i = 0; i < 4; i++) {
        lockout.recordWrongAttempt(Duration.zero);
      }
      expect(lockout.isLockedOut(Duration.zero), isFalse);
    });

    test('the 5th consecutive wrong attempt triggers lockout', () {
      final lockout = CodeLockout();
      for (var i = 0; i < 5; i++) {
        lockout.recordWrongAttempt(Duration.zero);
      }
      expect(lockout.isLockedOut(Duration.zero), isTrue);
    });

    test('during lockout, a correct code is still rejected', () {
      final lockout = CodeLockout();
      for (var i = 0; i < 5; i++) {
        lockout.recordWrongAttempt(Duration.zero);
      }
      expect(lockout.isLockedOut(const Duration(minutes: 5)), isTrue);
      // A caller must check isLockedOut before accepting any code; recording
      // a correct attempt while locked out must not clear the lockout.
      lockout.recordCorrectAttempt(const Duration(minutes: 5));
      expect(lockout.isLockedOut(const Duration(minutes: 5)), isTrue);
    });

    test('lockout ends after 15 minutes of monotonic elapsed time', () {
      final lockout = CodeLockout();
      for (var i = 0; i < 5; i++) {
        lockout.recordWrongAttempt(Duration.zero);
      }
      expect(
        lockout.isLockedOut(const Duration(minutes: 14, seconds: 59)),
        isTrue,
      );
      expect(lockout.isLockedOut(const Duration(minutes: 15)), isFalse);
    });

    test('a correct code before the 5th wrong one resets the counter', () {
      final lockout = CodeLockout()
        ..recordWrongAttempt(Duration.zero)
        ..recordWrongAttempt(Duration.zero)
        ..recordWrongAttempt(Duration.zero)
        ..recordWrongAttempt(Duration.zero)
        ..recordCorrectAttempt(Duration.zero);

      // The counter is back to zero: 4 more wrong attempts should not lock.
      for (var i = 0; i < 4; i++) {
        lockout.recordWrongAttempt(Duration.zero);
      }
      expect(lockout.isLockedOut(Duration.zero), isFalse);
    });

    test(
      'after lockout expires, a fresh set of 5 wrong attempts locks again',
      () {
        final lockout = CodeLockout();
        for (var i = 0; i < 5; i++) {
          lockout.recordWrongAttempt(Duration.zero);
        }
        expect(lockout.isLockedOut(const Duration(minutes: 15)), isFalse);

        for (var i = 0; i < 5; i++) {
          lockout.recordWrongAttempt(const Duration(minutes: 15));
        }
        expect(lockout.isLockedOut(const Duration(minutes: 15)), isTrue);
      },
    );

    test(
      'recording a wrong attempt while already locked out keeps it locked',
      () {
        final lockout = CodeLockout();
        for (var i = 0; i < 5; i++) {
          lockout.recordWrongAttempt(Duration.zero);
        }
        lockout.recordWrongAttempt(const Duration(minutes: 1));
        expect(lockout.isLockedOut(const Duration(minutes: 1)), isTrue);
        expect(lockout.isLockedOut(const Duration(minutes: 15)), isFalse);
      },
    );
  });
}
