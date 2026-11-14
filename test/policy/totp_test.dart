import 'dart:convert';
import 'dart:io';

import 'package:blocker/policy/totp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateCode (RFC 6238 SHA-1 vectors)', () {
    final file = File('test_vectors/totp/rfc6238_sha1.json');
    final vectors = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    final secret = vectors['secretBase32']! as String;
    final cases = vectors['cases']! as List<Object?>;

    for (final rawCase in cases) {
      final testCase = rawCase! as Map<String, Object?>;
      final unixSeconds = testCase['unixSeconds']! as int;
      final expectedCode = testCase['expectedCode']! as String;

      test('matches RFC 6238 vector at $unixSeconds seconds', () {
        expect(
          generateCode(secret: secret, unixSeconds: unixSeconds),
          expectedCode,
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

    test('rejects a secret that decodes to no usable bytes', () {
      expect(
        () => generateCode(secret: 'A', unixSeconds: 59),
        throwsArgumentError,
      );
    });

    test('never includes the secret in a thrown error message', () {
      const secretValue = 'super-secret-value-should-not-leak';
      expect(
        () => generateCode(secret: secretValue, unixSeconds: 59),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.toString(),
            'toString()',
            isNot(contains(secretValue)),
          ),
        ),
      );
    });
  });

  group('base32Decode (RFC 4648 vectors)', () {
    final file = File('test_vectors/totp/base32_rfc4648.json');
    final vectors = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    final cases = vectors['cases']! as List<Object?>;

    for (final rawCase in cases) {
      final testCase = rawCase! as Map<String, Object?>;
      final secretBase32 = testCase['secretBase32']! as String;
      final decodedAscii = testCase['decodedAscii']! as String;

      test('decodes $secretBase32 to "$decodedAscii"', () {
        expect(base32Decode(secretBase32), utf8.encode(decodedAscii));
      });
    }
  });

  group('isValidCode', () {
    const secret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

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
