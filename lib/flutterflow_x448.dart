import 'dart:convert';
import 'dart:typed_data';
import 'x448.dart';

Future<String> x448GeneratePrivateKeyB64() async {
  final kp = await X448.generate();
  return base64Encode(kp.privateKey);
}

Future<String> x448PublicKeyFromPrivateB64(String privB64) async {
  final priv = Uint8List.fromList(base64Decode(privB64));
  final pub = X448.publicKey(priv);
  return base64Encode(pub);
}

Future<String> x448SharedSecretB64(String myPrivB64, String peerPubB64) async {
  final priv = Uint8List.fromList(base64Decode(myPrivB64));
  final pub = Uint8List.fromList(base64Decode(peerPubB64));
  final ss = X448.sharedSecret(privateKey: priv, peerPublicKey: pub);
  return base64Encode(ss);
}
