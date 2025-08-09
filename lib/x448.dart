library x448_dart;

import 'dart:typed_data';

// Choose the backend: pure Dart everywhere for now.
import 'src/backend_pure.dart';

/// 56-byte little-endian scalars and u-coordinates.
class X448KeyPair {
  final Uint8List privateKey; // 56 bytes
  final Uint8List publicKey; // 56 bytes
  const X448KeyPair(this.privateKey, this.publicKey);
}

abstract class X448 {
  /// Generate a random private key (56 bytes), clamp, and derive public key.
  static Future<X448KeyPair> generate() async {
    final priv = await backendGeneratePrivateKey();
    final pub = backendPublicKey(priv);
    return X448KeyPair(priv, pub);
  }

  /// Derive public key from a clamped private key (56 bytes).
  static Uint8List publicKey(Uint8List privateKey) =>
      backendPublicKey(privateKey);

  /// Compute shared secret X448(k, peerU) → 56 bytes (raw). NOT a KDF.
  static Uint8List sharedSecret({
    required Uint8List privateKey,
    required Uint8List peerPublicKey,
  }) =>
      backendSharedSecret(privateKey: privateKey, peerPublicKey: peerPublicKey);
}
