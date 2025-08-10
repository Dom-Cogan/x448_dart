import 'dart:typed_data';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as jsu;

// Declare the JS functions we export from x448_wasm.js
@js.JS('x448_init')
external js.JSPromise _x448Init();

@js.JS('x448_public_from_private')
external js.JSAny _x448Pub(js.JSAny priv);

@js.JS('x448_shared')
external js.JSAny _x448Shared(js.JSAny priv, js.JSAny peer);

bool wasmReady = false;

Future<bool> wasmAvailable() async {
  if (wasmReady) return true;
  try {
    await _x448Init().toDart;
    wasmReady = true;
    return true;
  } catch (_) {
    return false;
  }
}

Uint8List wasmPublicKey(Uint8List priv) {
  final jsArr = jsu.createJSUint8ArrayFromDart(priv);
  final out = _x448Pub(jsArr) as js.JSUint8Array;
  return jsu.dartView(out);
}

Uint8List wasmShared(Uint8List priv, Uint8List peer) {
  final a = jsu.createJSUint8ArrayFromDart(priv);
  final b = jsu.createJSUint8ArrayFromDart(peer);
  final out = _x448Shared(a, b) as js.JSUint8Array;
  return jsu.dartView(out);
}
