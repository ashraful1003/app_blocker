import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

const _timeStepSeconds = 30;
const _codeDigits = 6;
const _toleranceSteps = 1;

/// RFC 6238 TOTP code for [secret] (an ASCII shared secret) at [unixSeconds].
String generateCode({required String secret, required int unixSeconds}) {
  final counter = unixSeconds ~/ _timeStepSeconds;
  return _hotp(secret: secret, counter: counter);
}

/// Whether [code] matches [secret] at [unixSeconds], allowing codes from
/// one time step before or after (clock drift tolerance).
bool isValidCode(
  String code, {
  required String secret,
  required int unixSeconds,
}) {
  if (!RegExp(r'^\d{6}$').hasMatch(code)) return false;

  final counter = unixSeconds ~/ _timeStepSeconds;
  for (var offset = -_toleranceSteps; offset <= _toleranceSteps; offset++) {
    if (_hotp(secret: secret, counter: counter + offset) == code) {
      return true;
    }
  }
  return false;
}

String _hotp({required String secret, required int counter}) {
  final key = utf8.encode(secret);
  final counterBytes = ByteData(8)..setInt64(0, counter);
  final hash = Hmac(sha1, key).convert(counterBytes.buffer.asUint8List()).bytes;

  final offset = hash[hash.length - 1] & 0xf;
  final binary =
      (hash[offset] & 0x7f) << 24 |
      (hash[offset + 1] & 0xff) << 16 |
      (hash[offset + 2] & 0xff) << 8 |
      (hash[offset + 3] & 0xff);

  final code = binary % _pow10(_codeDigits);
  return code.toString().padLeft(_codeDigits, '0');
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
