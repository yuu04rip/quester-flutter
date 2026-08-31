// lib/domain/security/password_hasher.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static const int iterations = 120000;
  static const int keyLength = 32; // 256 bit = 32 byte

  /// Genera l'hash di una password con salt casuale
  static String hash(String password) {
    final salt = _generateSalt();
    final hash = _pbkdf2(password, salt, iterations, keyLength);

    final saltB64 = base64Encode(salt);
    final hashB64 = base64Encode(hash);

    return '$iterations:$saltB64:$hashB64';
  }

  /// Verifica se una password corrisponde all'hash salvato
  static bool verify(String password, String stored) {
    final parts = stored.split(':');
    if (parts.length != 3) return false;

    final iterations = int.tryParse(parts[0]);
    if (iterations == null) return false;

    try {
      final salt = base64Decode(parts[1]);
      final expected = base64Decode(parts[2]);

      final actual = _pbkdf2(password, salt, iterations, expected.length);

      return _constantTimeEquals(actual, expected);
    } catch (_) {
      return false;
    }
  }

  /// Genera un salt casuale di 16 byte
  static List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  /// Implementazione PBKDF2-HMAC-SHA256
  static List<int> _pbkdf2(String password, List<int> salt, int iterations, int keyLength) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);

    final result = <int>[];
    final blockCount = (keyLength / 32).ceil();

    for (int blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      final block = _pbkdf2Block(hmac, salt, iterations, blockIndex);
      result.addAll(block);
    }

    return result.sublist(0, keyLength);
  }

  /// Calcola un singolo blocco di PBKDF2
  static List<int> _pbkdf2Block(Hmac hmac, List<int> salt, int iterations, int blockIndex) {
    final saltWithBlock = [...salt,
      (blockIndex >> 24) & 0xFF,
      (blockIndex >> 16) & 0xFF,
      (blockIndex >> 8) & 0xFF,
      blockIndex & 0xFF,
    ];

    var u = hmac.convert(saltWithBlock).bytes;
    final result = List<int>.from(u);

    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  /// Confronto in tempo costante
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}