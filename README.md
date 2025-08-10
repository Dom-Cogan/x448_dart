# x448_dart

X448 (RFC 7748) Elliptic-Curve Diffie–Hellman for Dart & Flutter.
Secure key generation, public key derivation, and shared secret computation, with FlutterFlow-friendly base64 helpers.

Status: scaffolded; pure Dart backend to be implemented next.


```dart
final alice = await X448.generate();
final bob   = await X448.generate();
final ss = X448.sharedSecret(privateKey: alice.privateKey, peerPublicKey: bob.publicKey);

// Turn shared secret into a 32-byte AES key (HKDF-SHA512)
final key32 = hkdfSha512(ikm: ss, info: utf8u('x448 session key'));
```

## Derive a symmetric key (HKDF-SHA512)

```dart
import 'package:x448_dart/hkdf.dart';

final ss = X448.sharedSecret(
  privateKey: alice.privateKey,
  peerPublicKey: bob.publicKey,
);

// 32-byte key (e.g., AES-256)
final key32 = hkdfSha512(
  ikm: ss,
  info: utf8u('x448 session key'),
  length: 32,
);
```
