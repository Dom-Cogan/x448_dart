// lib/src/backend_pure.dart
import 'dart:typed_data';
import 'utils.dart';

/// Prime p = 2^448 - 2^224 - 1  (Curve448 / RFC 7748)
final BigInt _p = (BigInt.one << 448) - (BigInt.one << 224) - BigInt.one;

const int _bytes = 56;       // 56-byte field elements/scalars
const int _a24 = 39081;      // (A + 2) / 4 for Curve448

// ---- helpers ----

BigInt _mod(BigInt x) {
  x %= _p;
  return x.isNegative ? x + _p : x;
}

BigInt _fromLE(Uint8List b) {
  BigInt x = BigInt.zero;
  for (int i = b.length - 1; i >= 0; i--) {
    x = (x << BigInt.from(8)) | BigInt.from(b[i]);
  }
  return x;
}

Uint8List _toLE(BigInt x, int len) {
  x = _mod(x);
  final out = Uint8List(len);
  for (int i = 0; i < len; i++) {
    out[i] = (x & BigInt.from(0xff)).toInt();
    x >>= 8;
  }
  return out;
}

BigInt _powMod(BigInt a, BigInt e) {
  a = _mod(a);
  BigInt r = BigInt.one;
  while (e > BigInt.zero) {
    if ((e & BigInt.one) == BigInt.one) r = _mod(r * a);
    a = _mod(a * a);
    e >>= 1;
  }
  return r;
}

/// Clamp per RFC 7748 (X448): k[0] &= 0xFC; k[55] |= 0x80;
Uint8List _clamp(Uint8List k) {
  if (k.length != _bytes) throw ArgumentError('X448 scalar must be 56 bytes');
  final out = Uint8List.fromList(k);
  clampX448(out); // from utils.dart
  return out;
}

// ---- core X448 ladder ----

Uint8List _x448(Uint8List scalar, Uint8List uBytes) {
  if (scalar.length != _bytes || uBytes.length != _bytes) {
    throw ArgumentError('X448 expects 56-byte inputs');
  }
  final k = _clamp(scalar);
  final x1 = _fromLE(uBytes);

  BigInt x2 = BigInt.one;
  BigInt z2 = BigInt.zero;
  BigInt x3 = _mod(x1);
  BigInt z3 = BigInt.one;
  int swap = 0;

  for (int t = 447; t >= 0; t--) {
    final bit = (k[t >> 3] >> (t & 7)) & 1;
    swap ^= bit;
    if (swap == 1) {
      // cswap(x2,z2) <-> (x3,z3)
      final tx = x2; x2 = x3; x3 = tx;
      final tz = z2; z2 = z3; z3 = tz;
    }
    swap = bit;

    final A  = _mod(x2 + z2);
    final B  = _mod(x2 - z2);
    final AA = _mod(A * A);
    final BB = _mod(B * B);
    final E  = _mod(AA - BB);

    final C  = _mod(x3 + z3);
    final D  = _mod(x3 - z3);
    final DA = _mod(D * A);
    final CB = _mod(C * B);

    x3 = _mod((DA + CB) * (DA + CB));
    z3 = _mod(_mod(x1) * (DA - CB) * (DA - CB));
    x2 = _mod(AA * BB);
    z2 = _mod(E * (_mod(BB + (BigInt.from(_a24) * E))));
  }

  if (swap == 1) {
    final tx = x2; x2 = x3; x3 = tx;
    final tz = z2; z2 = z3; z3 = tz;
  }

  final z2Inv = _powMod(z2, _p - BigInt.two); // inverse via Fermat
  final x = _mod(x2 * z2Inv);
  return _toLE(x, _bytes);
}

bool _isAllZero(Uint8List b) {
  int acc = 0;
  for (var v in b) acc |= v;
  return acc == 0;
}

// ---- public backend API (used by lib/x448.dart) ----

Future<Uint8List> backendGeneratePrivateKey() async {
  final k = randomBytes(_bytes);
  clampX448(k);
  return k;
}

Uint8List backendPublicKey(Uint8List privateKey) {
  if (privateKey.length != _bytes) {
    throw ArgumentError('X448 private key must be 56 bytes');
  }
  // Base point u = 5 → 56-byte little-endian
  final baseU = Uint8List(_bytes)..[0] = 5;
  return _x448(privateKey, baseU);
}

Uint8List backendSharedSecret({
  required Uint8List privateKey,
  required Uint8List peerPublicKey,
}) {
  if (privateKey.length != _bytes || peerPublicKey.length != _bytes) {
    throw ArgumentError('X448 inputs must be 56 bytes');
  }
  final ss = _x448(privateKey, peerPublicKey);
  if (_isAllZero(ss)) {
    throw StateError('X448 invalid shared secret (all zeros)');
  }
  return ss;
}
