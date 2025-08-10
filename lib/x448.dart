library x448_dart;

import 'dart:typed_data';

import 'src/backend_selector.dart';

/// 56-byte little-endian scalars and u-coordinates.
class X448KeyPair {
  final Uint8List privateKey; // 56 bytes
  final Uint8List publicKey;  // 56 bytes
  const X448KeyPair(this.privateKey, this.publicKey);
}

class X448 {
  /// Enforce constant-time backends (FFI/WASM). If true and CT backend is
  /// unavailable, methods throw [StateError].
  static bool requireConstantTime = false;

  /// Generate a random private key (56 bytes), clamp, and derive public key.
  static Future<X448KeyPair> generate() {
    Backend.requireCT = requireConstantTime;
    return Backend.generate();
  }

  /// Derive public key from a clamped private key (56 bytes).
  static Uint8List publicKey(Uint8List privateKey) {
    Backend.requireCT = requireConstantTime;
    return Backend.publicKey(privateKey);
  }

  /// Compute shared secret X448(k, peerU) → 56 bytes (raw). NOT a KDF.
  static Uint8List sharedSecret({
    required Uint8List privateKey,
    required Uint8List peerPublicKey,
  }) {
    Backend.requireCT = requireConstantTime;
    return Backend.sharedSecret(privateKey, peerPublicKey);
  }
}