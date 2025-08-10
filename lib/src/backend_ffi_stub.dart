import 'dart:typed_data';

// ignore_for_file: camel_case_types

bool ffiAvailable() => false;

Future<Uint8List> ffiGeneratePrivateKey() async =>
    throw StateError('FFI backend not available');

Uint8List ffiPublicKey(Uint8List priv) =>
    throw StateError('FFI backend not available');

Uint8List ffiSharedSecret(Uint8List priv, Uint8List peer) =>
    throw StateError('FFI backend not available');
