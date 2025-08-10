#include <stdint.h>
#include "../third_party/x448/include/point_448.h"

int x448_shared(uint8_t out[56], const uint8_t priv[56], const uint8_t peer_pub[56]) {
  c448_error_t err = x448_int(out, peer_pub, priv);
  return (err == C448_SUCCESS) ? 1 : 0;
}

void x448_public_from_private(uint8_t out_pub[56], const uint8_t priv[56]) {
  x448_derive_public_key(out_pub, priv);
}
