import 'dart:convert';
import 'package:x448_dart/x448.dart';

Future<void> main() async {
  try {
    final alice = await X448.generate();
    final bob   = await X448.generate();

    final s1 = X448.sharedSecret(privateKey: alice.privateKey, peerPublicKey: bob.publicKey);
    final s2 = X448.sharedSecret(privateKey: bob.privateKey,   peerPublicKey: alice.publicKey);

    print('equal? ${base64Encode(s1) == base64Encode(s2)}');
  } catch (e) {
    print('Backend not implemented yet: $e');
  }
}
