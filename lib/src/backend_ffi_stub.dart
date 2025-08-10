import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

final _rand = Random.secure();

typedef _x448_shared_c = ffi.Int32 Function(
  ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _x448_shared_dart = int Function(
  ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

typedef _x448_pub_c = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _x448_pub_dart = int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

_x448_shared_dart? _x448Shared;
_x448_pub_dart? _x448Pub;
ffi.DynamicLibrary? _lib;

void _tryLoadLibraryList(List<String> names, List<String> symPair) {
  for (final name in names) {
    try {
      final lib = name == '@process' ? ffi.DynamicLibrary.process() : ffi.DynamicLibrary.open(name);
      final shared = lib.lookup<ffi.NativeFunction<_x448_shared_c>>(symPair[0]).asFunction<_x448_shared_dart>();
      final pub    = lib.lookup<ffi.NativeFunction<_x448_pub_c>>(symPair[1]).asFunction<_x448_pub_dart>();
      _lib = lib; _x448Shared = shared; _x448Pub = pub;
      return;
    } catch (_) { /* try next */ }
  }
}

void _load() {
  if (_x448Shared != null && _x448Pub != null) return;

  // 1) Prefer our own shipped symbols (lowercase) from libx448dart
  //    - Android: libx448dart.so
  //    - iOS: linked static -> process()
  final ourNames = <String>[
    if (Platform.isAndroid) 'libx448dart.so',
    if (Platform.isIOS) '@process',
  ];
  if (ourNames.isNotEmpty) {
    _tryLoadLibraryList(ourNames, ['x448_shared', 'x448_public_from_private']);
    if (_x448Shared != null) return;
  }

  // 2) Fallback to libcrypto (desktop/server) with OpenSSL/BoringSSL symbols (uppercase)
  final cryptoNames = <String>[
    if (Platform.isLinux) ...['libcrypto.so.3', 'libcrypto.so'],
    if (Platform.isMacOS) ...['/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib', 'libcrypto.3.dylib', 'libcrypto.dylib'],
    if (Platform.isWindows) ...['libcrypto-3-x64.dll', 'libcrypto.dll'],
  ];
  if (cryptoNames.isNotEmpty) {
    _tryLoadLibraryList(cryptoNames, ['X448', 'X448_public_from_private']);
  }
}

bool ffiAvailable() {
  _load();
  return _x448Shared != null && _x448Pub != null;
}

Future<Uint8List> ffiGeneratePrivateKey() async {
  final out = Uint8List(56);
  for (var i = 0; i < out.length; i++) out[i] = _rand.nextInt(256);
  out[0] &= 0xFC; out[55] |= 0x80;
  return out;
}

Uint8List ffiPublicKey(Uint8List priv) {
  if (!ffiAvailable()) throw StateError('FFI backend unavailable');
  final out = calloc<ffi.Uint8>(56);
  final inP = calloc<ffi.Uint8>(56);
  for (var i = 0; i < 56; i++) inP[i] = priv[i];
  final rc = _x448Pub!(out, inP);
  final res = Uint8List.fromList(out.asTypedList(56));
  calloc.free(out); calloc.free(inP);
  if (rc != 1) throw StateError('x448_public_from_private failed');
  return res;
}

Uint8List ffiSharedSecret(Uint8List priv, Uint8List peer) {
  if (!ffiAvailable()) throw StateError('FFI backend unavailable');
  final out = calloc<ffi.Uint8>(56);
  final aP  = calloc<ffi.Uint8>(56);
  final bP  = calloc<ffi.Uint8>(56);
  for (var i = 0; i < 56; i++) { aP[i] = priv[i]; bP[i] = peer[i]; }
  final rc = _x448Shared!(out, aP, bP);
  final res = Uint8List.fromList(out.asTypedList(56));
  calloc.free(out); calloc.free(aP); calloc.free(bP);
  if (rc != 1) throw StateError('x448_shared failed');
  return res;
}
