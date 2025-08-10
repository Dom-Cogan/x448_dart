import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

final _rand = Random.secure();
ffi.DynamicLibrary? _lib;

typedef _X448Fn = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _X448 = int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

typedef _X448PubFn = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _X448Pub = int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

_X448? _x448;
_X448Pub? _x448Pub;

void _load() {
  if (_lib != null) return;
  final names = <String>[
    if (Platform.isLinux) ...['libcrypto.so.3', 'libcrypto.so'],
    if (Platform.isMacOS) ...['libcrypto.3.dylib', 'libcrypto.dylib'],
    if (Platform.isWindows) ...['libcrypto-3-x64.dll', 'libcrypto.dll'],
  ];
  for (final name in names) {
    try {
      _lib = ffi.DynamicLibrary.open(name);
      break;
    } catch (_) {
      continue;
    }
  }
  if (_lib != null) {
    try {
      _x448 = _lib!
          .lookup<ffi.NativeFunction<_X448Fn>>('X448')
          .asFunction();
      _x448Pub = _lib!
          .lookup<ffi.NativeFunction<_X448PubFn>>('X448_public_from_private')
          .asFunction();
    } catch (_) {
      _x448 = null;
      _x448Pub = null;
    }
  }
}

bool ffiAvailable() {
  _load();
  return _x448 != null && _x448Pub != null;
}

Future<Uint8List> ffiGeneratePrivateKey() async {
  final out = Uint8List(56);
  for (var i = 0; i < out.length; i++) {
    out[i] = _rand.nextInt(256);
  }
  out[0] &= 0xfc;
  out[55] |= 0x80;
  return out;
}

Uint8List ffiPublicKey(Uint8List priv) {
  if (!ffiAvailable()) {
    throw StateError('FFI backend unavailable');
  }
  final out = calloc<ffi.Uint8>(56);
  final ptrPriv = calloc<ffi.Uint8>(56);
  for (var i = 0; i < 56; i++) {
    ptrPriv[i] = priv[i];
  }
  _x448Pub!(out, ptrPriv);
  final result = Uint8List.fromList(out.asTypedList(56));
  calloc.free(out);
  calloc.free(ptrPriv);
  return result;
}

Uint8List ffiSharedSecret(Uint8List priv, Uint8List peer) {
  if (!ffiAvailable()) {
    throw StateError('FFI backend unavailable');
  }
  final out = calloc<ffi.Uint8>(56);
  final a = calloc<ffi.Uint8>(56);
  final b = calloc<ffi.Uint8>(56);
  for (var i = 0; i < 56; i++) {
    a[i] = priv[i];
    b[i] = peer[i];
  }
  final rc = _x448!(out, a, b);
  final result = Uint8List.fromList(out.asTypedList(56));
  calloc.free(out);
  calloc.free(a);
  calloc.free(b);
  if (rc != 1) {
    throw StateError('X448 failed');
  }
  return result;
}