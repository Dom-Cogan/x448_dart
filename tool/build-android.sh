#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.."; pwd)"
NDK_VERSION=r26d
API=21
NDK="$ROOT/.ndk/android-ndk-$NDK_VERSION"

# 1) Fetch Android NDK if missing
if [ ! -d "$NDK" ]; then
  mkdir -p "$ROOT/.ndk"
  cd "$ROOT/.ndk"
  echo "Downloading Android NDK $NDK_VERSION ..."
  curl -L -o ndk.zip "https://dl.google.com/android/repository/android-ndk-$NDK_VERSION-linux.zip"
  unzip -q ndk.zip
  echo "NDK at $NDK"
fi

# 2) Build static libx448.a per ABI using the NDK toolchain file
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64")
TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"

for ABI in "${ABIS[@]}"; do
  echo "==> Building x448 static lib for $ABI"
  BUILD_DIR="$ROOT/build-android/$ABI/x448"
  cmake -S "$ROOT/third_party/x448" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API" \
    -DANDROID_STL=c++_static \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN"
  cmake --build "$BUILD_DIR" --config Release -j
done

# 3) Compile our wrapper as a shared lib and link against the static x448 lib
echo "==> Building shared wrapper libx448dart.so"
mkdir -p "$ROOT/android/src/main/jniLibs"

# Triples for each ABI for direct clang invocation
triplet_for_abi() {
  case "$1" in
    arm64-v8a) echo "aarch64-linux-android";;
    armeabi-v7a) echo "armv7a-linux-androideabi";;
    x86_64) echo "x86_64-linux-android";;
    *) echo "unknown"; return 1;;
  esac
}

for ABI in "${ABIS[@]}"; do
  TRIPLE=$(triplet_for_abi "$ABI")
  [ "$TRIPLE" = "unknown" ] && { echo "Unknown ABI $ABI"; exit 1; }

  CC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${TRIPLE}${API}-clang"
  SYSROOT="$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
  OUT_DIR="$ROOT/build-android/$ABI"
  X448_BUILD="$OUT_DIR/x448"

  echo "---- $ABI"
  "$CC" -shared -fPIC \
    -I"$ROOT/third_party/x448/include" \
    "$ROOT/native/mobile_wrapper.c" \
    "$X448_BUILD/libx448.a" \
    -o "$OUT_DIR/libx448dart.so" \
    --sysroot "$SYSROOT"

  mkdir -p "$ROOT/android/src/main/jniLibs/$ABI"
  cp "$OUT_DIR/libx448dart.so" "$ROOT/android/src/main/jniLibs/$ABI/"
done

echo "All done. Libraries placed in android/src/main/jniLibs/{arm64-v8a,armeabi-v7a,x86_64}/"
