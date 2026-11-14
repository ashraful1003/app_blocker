import 'dart:typed_data';

import 'package:crypto/crypto.dart';

const _timeStepSeconds = 30;
const _codeDigits = 6;
const _toleranceSteps = 1;

final _codePattern = RegExp(r'^\d{6}$');
const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/// RFC 6238 TOTP code for [secret] (a base32-encoded shared secret, as
/// shown to authenticator apps) at [unixSeconds].
String generateCode({required String secret, required int unixSeconds}) {
  final counter = _counterFor(unixSeconds);
  return _hotp(key: _base32Decode(secret), counter: counter);
}

/// Whether [code] matches [secret] at [unixSeconds], allowing codes from
/// one time step before or after (clock drift tolerance). [secret] is the
/// base32-encoded shared secret, as shown to authenticator apps.
bool isValidCode(
  String code, {
  required String secret,
  required int unixSeconds,
}) {
  if (!_codePattern.hasMatch(code)) return false;

  final key = _base32Decode(secret);
  final counter = _counterFor(unixSeconds);
  var matched = false;
  for (var offset = -_toleranceSteps; offset <= _toleranceSteps; offset++) {
    final expected = _hotp(key: key, counter: counter + offset);
    if (_constantTimeEquals(expected, code)) matched = true;
  }
  return matched;
}

int _counterFor(int unixSeconds) {
  if (unixSeconds < 0) {
    throw ArgumentError.value(
      unixSeconds,
      'unixSeconds',
      'must not be negative',
    );
  }
  return unixSeconds ~/ _timeStepSeconds;
}

/// Compares two equal-length strings without leaking, via timing, how many
/// leading characters match — codes are compared on a security boundary.
bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

String _hotp({required List<int> key, required int counter}) {
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

/// Decodes an RFC 4648 base32 string (the format authenticator apps show
/// and scan via QR code) into raw key bytes. Padding ('=') is optional.
List<int> _base32Decode(String secret) {
  if (secret.isEmpty) {
    throw ArgumentError.value(secret, 'secret', 'must not be empty');
  }

  final cleaned = secret.toUpperCase().replaceAll('=', '');
  final bytes = <int>[];
  var buffer = 0;
  var bitsInBuffer = 0;

  for (final char in cleaned.split('')) {
    final value = _base32Alphabet.indexOf(char);
    if (value == -1) {
      throw ArgumentError.value(secret, 'secret', 'not valid base32');
    }
    buffer = (buffer << 5) | value;
    bitsInBuffer += 5;
    if (bitsInBuffer >= 8) {
      bitsInBuffer -= 8;
      bytes.add((buffer >> bitsInBuffer) & 0xff);
    }
  }

  if (bytes.isEmpty) {
    throw ArgumentError.value(secret, 'secret', 'must not be empty');
  }
  return bytes;
}
