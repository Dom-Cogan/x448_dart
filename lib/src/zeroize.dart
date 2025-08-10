import 'dart:typed_data';

void zeroize(Uint8List b) {
  for (var i = 0; i < b.length; i++) {
    b[i] = 0;
  }
}

T withSharedSecret<T>({
  required Uint8List privateKey,
  required Uint8List peerPublicKey,
  required T Function(Uint8List ss) fn,
  required Uint8List Function({
    required Uint8List privateKey,
    required Uint8List peerPublicKey,
  }) derive,
}) {
  final ss = derive(privateKey: privateKey, peerPublicKey: peerPublicKey);
  try {
    return fn(ss);
  } finally {
    zeroize(ss);
  }
}
