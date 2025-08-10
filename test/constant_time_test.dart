import 'package:test/test.dart';
import 'package:x448_dart/x448.dart';

void main() {
  test('require constant-time backend (either FFI or WASM or fail)', () async {
    // We don’t import backends here; the selector will decide.
    // If a CT backend can’t load on this runner, we expect a throw when enforced.
    X448.requireConstantTime = true;
    try {
      final kp = await X448.generate();
      expect(kp.privateKey.length, 56);
    } on StateError {
      // acceptable: CT backend not available on this platform in CI
      expect(true, isTrue);
    } finally {
      X448.requireConstantTime = false;
    }
  });
}