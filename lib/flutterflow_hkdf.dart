import 'dart:convert';
import 'dart:typed_data';
import 'hkdf.dart';

String hkdfSha512B64({
  required String sharedSecretB64,
  String? saltB64,
  String? infoUtf8,
  int length = 32,
}) {
  final ikm  = Uint8List.fromList(base64Decode(sharedSecretB64));
  final salt = (saltB64 == null) ? null : Uint8List.fromList(base64Decode(saltB64));
  final info = (infoUtf8 == null) ? null : utf8u(infoUtf8);
  final out  = hkdfSha512(ikm: ikm, salt: salt, info: info, length: length);
  return base64Encode(out);
}
