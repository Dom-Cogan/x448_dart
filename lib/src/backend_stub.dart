import 'dart:typed_data';

/// These stubs deliberately throw. We'll replace them with a pure Dart backend.
Future<Never> backendGenerate() async =>
    throw UnimplementedError('X448 backend not implemented yet.');

Uint8List backendPublicKey(Uint8List privateKey) =>
    throw UnimplementedError('X448 backend not implemented yet.');

Uint8List backendSharedSecret({
  required Uint8List privateKey,
  required Uint8List peerPublicKey,
}) =>
    throw UnimplementedError('X448 backend not implemented yet.');
