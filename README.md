# x448_dart

X448 (RFC 7748) Elliptic-Curve Diffie–Hellman for Dart & Flutter.  
Secure key generation, public key derivation, and shared secret computation, with FlutterFlow-friendly base64 helpers.

**Status:** ✅ Pure Dart backend implemented, RFC 7748-compliant, with full test coverage.

---

## Features
- **Pure Dart X448 ECDH** — no native dependencies, works everywhere Dart runs
- **RFC 7748 §5.2 test vectors** included
- **HKDF-SHA512** helpers for key derivation (binary + base64)
- Works with **Flutter**, **FlutterFlow**, and **Dart CLI**

---

## Example

```dart
import 'dart:convert';
import 'package:x448_dart/x448.dart';

Future<void> main() async {
  // Generate key pairs for Alice and Bob
  final alice = await X448.generate();
  final bob   = await X448.generate();

  // Each derives the same shared secret
  final s1 = X448.sharedSecret(
    privateKey: alice.privateKey,
    peerPublicKey: bob.publicKey,
  );
  final s2 = X448.sharedSecret(
    privateKey: bob.privateKey,
    peerPublicKey: alice.publicKey,
  );

  print('Equal? ${base64Encode(s1) == base64Encode(s2)}'); // true
}
