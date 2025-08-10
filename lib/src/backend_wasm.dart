import 'dart:typed_data';

// Placeholder WASM backend: not loaded by default.
// The selector will fall back to FFI or pure Dart.
// Later, wire this to JavaScript glue when shipping web support.

bool wasmReady = false;

Future<bool> wasmAvailable() async {
  return false;
}

Uint8List wasmPublicKey(Uint8List priv) {
  throw StateError('WASM backend is not loaded');
}

Uint8List wasmShared(Uint8List priv, Uint8List peer) {
  throw StateError('WASM backend is not loaded');
}
