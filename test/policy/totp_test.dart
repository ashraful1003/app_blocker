import 'package:blocker/policy/totp.dart';
import 'package:flutter_test/flutter_test.dart';

// RFC 6238 Appendix B test vectors (SHA-1), truncated to 6 digits
// (the standard 8-digit vectors mod 10^6).
const secret = '12345678901234567890';

void main() {
  group('generateCode (RFC 6238 SHA-1 vectors)', () {
    const vectors = <int, String>{
      59: '287082',
      1111111109: '081804',
      1111111111: '050471',
      1234567890: '005924',
      2000000000: '279037',
      20000000000: '353130',
    };

    for (final entry in vectors.entries) {
      test('matches RFC 6238 vector at ${entry.key} seconds', () {
        expect(
          generateCode(secret: secret, unixSeconds: entry.key),
          entry.value,
        );
      });
    }
  });

  group('isValidCode', () {
    test('accepts a code from the current time step', () {
      const now = 1111111109;
      final code = generateCode(secret: secret, unixSeconds: now);
      expect(isValidCode(code, secret: secret, unixSeconds: now), isTrue);
    });

    test('accepts a code from the previous time step (tolerance)', () {
      const now = 1111111109;
      final previousStepCode = generateCode(
        secret: secret,
        unixSeconds: now - 30,
      );
      expect(
        isValidCode(previousStepCode, secret: secret, unixSeconds: now),
        isTrue,
      );
    });

    test('rejects a code from two time steps ago', () {
      const now = 1111111109;
      final staleCode = generateCode(secret: secret, unixSeconds: now - 60);
      expect(isValidCode(staleCode, secret: secret, unixSeconds: now), isFalse);
    });

    test('rejects a code with too few digits', () {
      expect(isValidCode('1234', secret: secret, unixSeconds: 59), isFalse);
    });

    test('rejects a code with too many digits', () {
      expect(isValidCode('1234567', secret: secret, unixSeconds: 59), isFalse);
    });

    test('rejects a code with non-digit characters', () {
      expect(isValidCode('12a456', secret: secret, unixSeconds: 59), isFalse);
    });
  });
}
