// ignore_for_file: directives_ordering
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart' as c;

/// HKDF-SHA512: derive `length` bytes from `ikm` with optional `salt` and `info`.
Uint8List hkdfSha512({
  required Uint8List ikm,
  Uint8List? salt,
  Uint8List? info,
  int length = 32, // e.g., 32 for AES-256
}) {
  final zeroSalt = Uint8List(64); // RFC 5869: if salt missing, use zeros of hash length
  final prk = c.Hmac(c.sha512, (salt ?? zeroSalt)).convert(ikm).bytes;

  final List<int> okm = [];
  List<int> t = [];
  int counter = 1;

  while (okm.length < length) {
    final input = <int>[...t, ...(info ?? const []), counter];
    t = c.Hmac(c.sha512, prk).convert(input).bytes;
    okm.addAll(t);
    counter++;
  }
  return Uint8List.fromList(okm.sublist(0, length));
}

/// tiny helpers
Uint8List utf8u(String s) => Uint8List.fromList(utf8.encode(s));
String b64(Uint8List b) => base64Encode(b);
Uint8List deb64(String s) => Uint8List.fromList(base64Decode(s));
