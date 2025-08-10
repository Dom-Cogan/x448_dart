import 'dart:math';
import 'dart:typed_data';

// Import FFI and WASM backends with guards so web doesn’t see dart:ffi symbols.
import 'backend_ffi_stub.dart' as ffi
  if (dart.library.io) 'backend_ffi.dart';
import 'backend_wasm.dart' as wasm
  if (dart.library.js_interop) 'backend_wasm.dart';

import 'backend_pure.dart' as pure;
import '../x448.dart' show X448KeyPair;

class Backend {
  static bool requireCT = false;

  static Future<X448KeyPair> generate() async {
    // Prefer FFI (desktop/mobile) if available.
    if (_ffiAvailableSafe()) {
      final priv = await ffi.ffiGeneratePrivateKey();
      final pub  = ffi.ffiPublicKey(priv);
      return X448KeyPair(priv, pub);
    }
    // Prefer WASM on web if available.
    if (await _wasmAvailableSafe()) {
      final rand = Random.secure();
      final priv = Uint8List(56);
      for (var i = 0; i < priv.length; i++) {
        priv[i] = rand.nextInt(256);
      }
      priv[0] &= 0xfc;
      priv[55] |= 0x80;
      final pub = wasm.wasmPublicKey(priv);
      return X448KeyPair(priv, pub);
    }
    if (requireCT) {
      throw StateError('Constant-time backend not available on this platform.');
    }
    final priv = await pure.backendGeneratePrivateKey();
    final pub  = pure.backendPublicKey(priv);
    return X448KeyPair(priv, pub);
  }

  static Uint8List publicKey(Uint8List priv) {
    if (_ffiAvailableSafe()) return ffi.ffiPublicKey(priv);
    if (wasm.wasmReady)      return wasm.wasmPublicKey(priv);
    if (requireCT) {
      throw StateError('Constant-time backend not available.');
    }
    return pure.backendPublicKey(priv);
  }

  static Uint8List sharedSecret(Uint8List priv, Uint8List peer) {
    if (_ffiAvailableSafe()) return ffi.ffiSharedSecret(priv, peer);
    if (wasm.wasmReady)      return wasm.wasmShared(priv, peer);
    if (requireCT) {
      throw StateError('Constant-time backend not available.');
    }
    return pure.backendSharedSecret(privateKey: priv, peerPublicKey: peer);
  }
}

bool _ffiAvailableSafe() {
  try { return ffi.ffiAvailable(); } catch (_) { return false; }
}

Future<bool> _wasmAvailableSafe() async {
  try { return await wasm.wasmAvailable(); } catch (_) { return false; }
}