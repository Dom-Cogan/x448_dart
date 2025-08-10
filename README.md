# x448_dart

Cross‑platform X448 (RFC 7748) Elliptic‑Curve Diffie–Hellman for Dart, Flutter, and FlutterFlow.

This package provides secure key generation, public key derivation, and shared
secret computation with optional HKDF‑SHA512 and memory zeroization
utilities. Constant‑time implementations are supplied via FFI
(OpenSSL/BoringSSL) and WebAssembly, with a pure Dart fallback for platforms
where a constant‑time backend is unavailable.

## Features

- ✈️ **Cross‑platform**: Android, iOS, macOS, Windows, Linux, Web, and
  Dart CLI
- 🔒 **Constant‑time** backends with optional enforcement via
  `X448.requireConstantTime`
- 🧪 **RFC 7748 test vectors** included
- 🔍 **HKDF‑SHA512** helper (`hkdfSha512`) and FlutterFlow‑friendly
  Base64 wrappers
- 🗑️ **Zeroization helpers** (`zeroize`, `withSharedSecret`) to
  wipe secrets from memory

## Security

Set `X448.requireConstantTime = true;` before calling APIs to require a
constant‑time backend. If none is available, the methods throw `StateError`.
Without this flag the library falls back to a pure Dart implementation that is
*not* constant‑time.

### Platform matrix

| Platform | Backend | Constant-time |
|---------|---------|---------------|
| Android / iOS | FFI (BoringSSL) | ✅ |
| macOS / Windows / Linux | FFI (OpenSSL) | ✅ |
| Web | WebAssembly | ✅ |
| Dart VM fallback | Pure Dart | ❌ |

## Usage

```dart
import 'dart:convert';
import 'package:x448_dart/x448.dart';

Future<void> main() async {
  final alice = await X448.generate();
  final bob   = await X448.generate();

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
```

## FlutterFlow helpers

`flutterflow_x448.dart` and `flutterflow_hkdf.dart` expose Base64‑friendly
wrappers for FlutterFlow custom actions.

## License

[MIT](LICENSE)

