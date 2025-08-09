import 'package:test/test.dart';
import 'package:x448_dart/x448.dart';

void main() {
  test('ECDH round-trip: Alice/Bob derive same secret', () async {
    final a = await X448.generate();
    final b = await X448.generate();

    final s1 = X448.sharedSecret(
      privateKey: a.privateKey,
      peerPublicKey: b.publicKey,
    );
    final s2 = X448.sharedSecret(
      privateKey: b.privateKey,
      peerPublicKey: a.publicKey,
    );

    expect(s1.length, 56);
    expect(s2.length, 56);
    expect(s1, equals(s2));
  });
}
