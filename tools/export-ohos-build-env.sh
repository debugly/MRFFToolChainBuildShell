#! /usr/bin/env bash
#
# Copyright (C) 2021 Matt Reach<qianlongxu@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case $_MR_ARCH in
    x86_64)
        export MR_TRIPLE=x86_64-linux-ohos
        export MR_FF_ARCH=x86_64
        export MR_OHOS_ABI=x86_64
    ;;
    arm64*)
        export MR_TRIPLE=aarch64-linux-ohos
        export MR_FF_ARCH=aarch64
        export MR_OHOS_ABI=arm64-v8a
    ;;
    *)
        echo "unknown architecture $_MR_ARCH";
        exit 1
    ;;
esac

export MR_ARCH="$_MR_ARCH"

# Common prefix for ld, as, etc.
CROSS_PREFIX_WITH_PATH=${MR_TOOLCHAIN_ROOT}/bin/llvm-

# Exporting Binutils paths. The MR_ prefix avoids leaking them to build systems.
export  MR_ADDR2LINE=${CROSS_PREFIX_WITH_PATH}addr2line
export         MR_AR=${CROSS_PREFIX_WITH_PATH}ar
export         MR_NM=${CROSS_PREFIX_WITH_PATH}nm
export    MR_OBJCOPY=${CROSS_PREFIX_WITH_PATH}objcopy
export    MR_OBJDUMP=${CROSS_PREFIX_WITH_PATH}objdump
export     MR_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
export    MR_READELF=${CROSS_PREFIX_WITH_PATH}readelf
export       MR_SIZE=${CROSS_PREFIX_WITH_PATH}size
export    MR_STRINGS=${CROSS_PREFIX_WITH_PATH}strings
export      MR_STRIP=${CROSS_PREFIX_WITH_PATH}strip

# OHOS clang ships no triple-prefixed wrappers: use plain clang and drive the
# target through --target/--sysroot in MR_DEFAULT_CFLAGS below.
export  MR_TRIPLE_CC=${MR_TOOLCHAIN_ROOT}/bin/clang
export MR_TRIPLE_CXX=${MR_TOOLCHAIN_ROOT}/bin/clang++
export         MR_CC=${MR_TOOLCHAIN_ROOT}/bin/clang
export        MR_CXX=${MR_TOOLCHAIN_ROOT}/bin/clang++
export         MR_AS=${MR_TOOLCHAIN_ROOT}/bin/clang

# -D__OHOS__ marks the platform in third-party sources; --target/--sysroot drive clang.
export MR_DEFAULT_CFLAGS="$MR_INIT_CFLAGS --target=$MR_TRIPLE --sysroot=$MR_SYS_ROOT -D__OHOS__"

# ohos/ffmpeg-x86_64
export MR_BUILD_SOURCE="${MR_SRC_ROOT}/${REPO_DIR}-${_MR_ARCH}"
# ohos/fftutorial-x86_64
export MR_BUILD_PREFIX="${MR_PRODUCT_ROOT}/${LIB_NAME}-${_MR_ARCH}"

echo "MR_ARCH         : [$MR_ARCH]"
echo "MR_TRIPLE       : [$MR_TRIPLE]"
echo "MR_OHOS_ABI     : [$MR_OHOS_ABI]"
echo "MR_OHOS_NATIVE  : [$MR_OHOS_NATIVE]"
echo "MR_BUILD_SOURCE : [$MR_BUILD_SOURCE]"
echo "MR_BUILD_PREFIX : [$MR_BUILD_PREFIX]"
echo "MR_DEFAULT_CFLAGS : [$MR_DEFAULT_CFLAGS]"

# ---------------------------------------------------------------------------
# Generate a meson crossfile with concrete --target/--sysroot paths. The OHOS
# clang ships no triple-prefixed wrappers, so the target must be passed
# explicitly; the sysroot path is SDK-specific and can't live in a static file.
# ---------------------------------------------------------------------------
MR_OHOS_MESON_CROSSFILE="${MR_WORKSPACE}/.ohos-cross/${_MR_ARCH}-ohos.meson"
mkdir -p "$(dirname "$MR_OHOS_MESON_CROSSFILE")"
cat > "$MR_OHOS_MESON_CROSSFILE" <<EOF
[binaries]
c = '${MR_TOOLCHAIN_ROOT}/bin/clang'
cpp = '${MR_TOOLCHAIN_ROOT}/bin/clang++'
ar = '${MR_TOOLCHAIN_ROOT}/bin/llvm-ar'
strip = '${MR_TOOLCHAIN_ROOT}/bin/llvm-strip'
ranlib = '${MR_TOOLCHAIN_ROOT}/bin/llvm-ranlib'
pkg-config = 'pkg-config'

[properties]
c_args = ['--target=${MR_TRIPLE}', '--sysroot=${MR_SYS_ROOT}']
c_link_args = ['--target=${MR_TRIPLE}', '--sysroot=${MR_SYS_ROOT}', '-fuse-ld=lld']
cpp_args = ['--target=${MR_TRIPLE}', '--sysroot=${MR_SYS_ROOT}']
cpp_link_args = ['--target=${MR_TRIPLE}', '--sysroot=${MR_SYS_ROOT}', '-fuse-ld=lld']
needs_exe_wrapper = true

[host_machine]
system = 'linux'
cpu_family = '${MR_FF_ARCH}'
cpu = '${MR_FF_ARCH}'
endian = 'little'
EOF
export MR_OHOS_MESON_CROSSFILE
echo "MR_OHOS_MESON_CROSSFILE: [$MR_OHOS_MESON_CROSSFILE]"

#
THIS_DIR=$(DIRNAME=$(dirname "${BASH_SOURCE[0]}"); cd "$DIRNAME"; pwd)
source "$THIS_DIR/export-ohos-pkg-config-dir.sh"

echo "PKG_CONFIG_LIBDIR: [$PKG_CONFIG_LIBDIR]"
