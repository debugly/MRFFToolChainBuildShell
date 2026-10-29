#!/usr/bin/env bash
set -e

: "${MR_BUILD_SOURCE:?}"
: "${MR_BUILD_PREFIX:?}"
: "${MR_CC:?}"
pkg-config --exists libavutil libass
mkdir -p "$MR_BUILD_PREFIX/lib/pkgconfig" "$MR_BUILD_PREFIX/include"

# Match the compiler and target flags exported by each platform's environment.
cc=$MR_CC
ar=${MR_AR:-ar}
case "$MR_PLAT" in
    ios|macos|tvos) ar="$(xcrun -f ar)" ;;
    android) cc=$MR_TRIPLE_CC ;;
    ohos) ;;
    *) echo "Unsupported test platform: $MR_PLAT" >&2; exit 1 ;;
esac
$cc $MR_DEFAULT_CFLAGS -fPIC $(pkg-config --cflags libavutil libass) \
    -c "$MR_BUILD_SOURCE/test.c" -o "$MR_BUILD_SOURCE/test.o"
# Recreate the archive so a rebuild cannot retain stale members.
rm -f "$MR_BUILD_PREFIX/lib/libtest.a"
"$ar" rcs "$MR_BUILD_PREFIX/lib/libtest.a" "$MR_BUILD_SOURCE/test.o"
cp "$MR_BUILD_SOURCE/test.h" "$MR_BUILD_PREFIX/include/"
cat > "$MR_BUILD_PREFIX/lib/pkgconfig/test.pc" <<PC
prefix=$MR_BUILD_PREFIX
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: test
Description: Print the linked FFmpeg and libass versions
Version: $GIT_REPO_VERSION
Requires.private: libavutil libass
Libs: -L\${libdir} -ltest
Cflags: -I\${includedir}
PC
