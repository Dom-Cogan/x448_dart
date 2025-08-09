import 'dart:typed_data';

Future<Uint8List> backendGeneratePrivateKey() async =>
    throw UnimplementedError('X448 backend not implemented yet.');

Uint8List backendPublicKey(Uint8List privateKey) =>
    throw UnimplementedError('X448 backend not implemented yet.');

Uint8List backendSharedSecret({
  required Uint8List privateKey,
  required Uint8List peerPublicKey,
}) =>
    throw UnimplementedError('X448 backend not implemented yet.');
