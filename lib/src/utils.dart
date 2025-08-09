import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

Uint8List randomBytes(int n) {
  final rng = Random.secure();
  final b = Uint8List(n);
  for (var i = 0; i < n; i++) {
    b[i] = rng.nextInt(256);
  }
  return b;
}

/// RFC 7748 X448 clamping: k[0] &= 0xFC; k[55] |= 0x80;
void clampX448(Uint8List k) {
  if (k.length != 56) {
    throw ArgumentError('X448 private key must be 56 bytes');
  }
  k[0] &= 0xFC;
  k[55] |= 0x80;
}

void zeroize(Uint8List b) {
  for (var i = 0; i < b.length; i++) {
    b[i] = 0;
  }
}

String b64(Uint8List b) => base64Encode(b);
Uint8List deb64(String s) => Uint8List.fromList(base64Decode(s));

String hex(Uint8List b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
Uint8List dehex(String s) {
  final out = Uint8List(s.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(s.substring(2 * i, 2 * i + 2), radix: 16);
  }
  return out;
}
