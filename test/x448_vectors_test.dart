import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:x448_dart/x448.dart';

Uint8List dehex(String s) {
  final clean = s.replaceAll(RegExp(r'\s+'), '');
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(clean.substring(2 * i, 2 * i + 2), radix: 16);
  }
  return out;
}

void main() {
  group('RFC 7748 §5.2 X448 function vectors', () {
    test('Vector 1', () {
      final k = dehex(
        '3d262fddf9ec8e88495266fea19a34d28882acef045104d0d1aae121'
        '700a779c984c24f8cdd78fbff44943eba368f54b29259a4f1c600ad3',
      );
      final u = dehex(
        '06fce640fa3487bfda5f6cf2d5263f8aad88334cbd07437f020f08f9'
        '814dc031ddbdc38c19c6da2583fa5429db94ada18aa7a7fb4ef8a086',
      );
      final expectHex =
        'ce3e4ff95a60dc6697da1db1d85e6afbdf79b50a2412d7546d5f239f'
        'e14fbaadeb445fc66a01b0779d98223961111e21766282f73dd96b6f';

      final out = X448.sharedSecret(privateKey: k, peerPublicKey: u);
      expect(out.length, 56);
      final gotHex = out.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      expect(gotHex, expectHex);
    });

    test('Vector 2', () {
      final k = dehex(
        '203d494428b8399352665ddca42f9de8fef600908e0d461cb021f8c5'
        '38345dd77c3e4806e25f46d3315c44e0a5b4371282dd2c8d5be3095f',
      );
      final u = dehex(
        '0fbcc2f993cd56d3305b0b7d9e55d4c1a8fb5dbb52f8e9a1e9b6201b'
        '165d015894e56c4d3570bee52fe205e28a78b91cdfbde71ce8d157db',
      );
      final expectHex =
        '884a02576239ff7a2f2f63b2db6a9ff37047ac13568e1e30fe63c4a7'
        'ad1b3ee3a5700df34321d62077e63633c575c1c954514e99da7c179d';

      final out = X448.sharedSecret(privateKey: k, peerPublicKey: u);
      expect(out.length, 56);
      final gotHex = out.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      expect(gotHex, expectHex);
    });
  });

  group('RFC 7748 §5.2 X448 iteration (after 1 iteration)', () {
    test('one-iteration value', () {
      // Initial k and u (56-byte little-endian each)
      final k0 = dehex(
        '05' + '00' * 55
      );
      final u0 = dehex(
        '05' + '00' * 55
      );

      // one iteration: new_k = X448(k0, u0)
      final k1 = X448.sharedSecret(privateKey: k0, peerPublicKey: u0);

      final expectHex =
        '3f482c8a9f19b01e6c46ee9711d9dc14fd4bf67af30765c2ae2b846a'
        '4d23a8cd0db897086239492caf350b51f833868b9bc2b3bca9cf4113';

      final gotHex = k1.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      expect(gotHex, expectHex);
    });
  });
}
