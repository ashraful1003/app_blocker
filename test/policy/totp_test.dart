import 'package:blocker/policy/totp.dart';
import 'package:flutter_test/flutter_test.dart';

// RFC 6238 Appendix B test vectors (SHA-1), truncated to 6 digits
// (the standard 8-digit vectors mod 10^6). The RFC's key is the ASCII
// string '12345678901234567890'; base32-encoded, as a real secret would be
// shown to an authenticator app, that is 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'.
const secret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

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

    test('accepts a lowercase secret the same as uppercase', () {
      expect(
        generateCode(secret: secret.toLowerCase(), unixSeconds: 59),
        generateCode(secret: secret, unixSeconds: 59),
      );
    });

    test('rejects a negative timestamp', () {
      expect(
        () => generateCode(secret: secret, unixSeconds: -1),
        throwsArgumentError,
      );
    });

    test('rejects an empty secret', () {
      expect(
        () => generateCode(secret: '', unixSeconds: 59),
        throwsArgumentError,
      );
    });

    test('rejects a secret with non-base32 characters', () {
      expect(
        () => generateCode(secret: '1234', unixSeconds: 59),
        throwsArgumentError,
      );
    });
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
