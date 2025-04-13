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
# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
# https://developer.android.com/ndk/guides/abis?hl=zh-cn#cmake_1


export MR_ANDROID_API=21

case $_MR_ARCH in
    *v7a)
    export MR_TRIPLE=armv7a-linux-androideabi$MR_ANDROID_API
    export MR_FF_ARCH=arm
    export MR_ANDROID_ABI=armeabi-v7a
    ;;
    x86)
    export MR_TRIPLE=i686-linux-android$MR_ANDROID_API
    export MR_FF_ARCH=i686
    export MR_ANDROID_ABI=x86
    ;;
    x86_64)
    export MR_TRIPLE=x86_64-linux-android$MR_ANDROID_API
    export MR_FF_ARCH=x86_64
    export MR_ANDROID_ABI=x86_64
    ;;
    arm64*)
    export MR_TRIPLE=aarch64-linux-android$MR_ANDROID_API
    export MR_FF_ARCH=aarch64
    export MR_ANDROID_ABI=arm64-v8a
    ;;
    *)
    echo "unknown architecture $_MR_ARCH";
    exit 1
    ;;
esac

# x86_64
export MR_ARCH="$_MR_ARCH"
# openssl-armv7a
export MR_BUILD_NAME="${REPO_DIR}-${_MR_ARCH}"
# android/ffmpeg-x86_64
export MR_BUILD_SOURCE="${MR_SRC_ROOT}/${MR_BUILD_NAME}"
# android/ffmpeg-x86_64
export MR_BUILD_PREFIX="${MR_PRODUCT_ROOT}/${MR_BUILD_NAME}"

if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "You must define ANDROID_NDK_HOME before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
else
    export MR_NDK_REL=$(grep -m 1 -o '^## r[0-9]*.*' $ANDROID_NDK_HOME/CHANGELOG.md | awk '{print $2}')
fi

export MR_ANDROID_NDK_HOME="$ANDROID_NDK_HOME"
export MR_TOOLCHAIN_ROOT="$MR_ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${MR_HOST_TAG}"
export PATH="${MR_TOOLCHAIN_ROOT}/bin:$PATH"
export MR_SYS_ROOT="${MR_TOOLCHAIN_ROOT}/sysroot"

# Common prefix for ld, as, etc.
CROSS_PREFIX_WITH_PATH=${MR_TOOLCHAIN_ROOT}/bin/llvm-

# Exporting Binutils paths, if passing just CROSS_PREFIX_WITH_PATH is not enough
# The MR_ prefix is used to eliminate passing those values implicitly to build systems
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
export       MR_LIPO=${CROSS_PREFIX_WITH_PATH}lipo
# ffmpeg can't use triple target clang
export  MR_TRIPLE_CC=${MR_TOOLCHAIN_ROOT}/bin/${MR_TRIPLE}-clang
export MR_TRIPLE_CXX=${MR_TRIPLE_CC}++
# find clang from NDK toolchain
export         MR_CC=${MR_TOOLCHAIN_ROOT}/bin/clang
export        MR_CXX=${MR_CC}++
# llvm-as for LLVM IR
# export         MR_AS=${CROSS_PREFIX_WITH_PATH}as
export         MR_AS=${MR_TRIPLE_CC}
export       MR_YASM=${MR_TOOLCHAIN_ROOT}/bin/yasm


export MR_DEFAULT_CFLAGS="$MR_INIT_CFLAGS -D__ANDROID__"


echo "MR_ARCH         : [$MR_ARCH]"
echo "MR_TRIPLE       : [$MR_TRIPLE]"
echo "MR_ANDROID_API  : [$MR_ANDROID_API]"
echo "MR_ANDROID_NDK  : [$MR_NDK_REL]"
echo "MR_BUILD_NAME   : [$MR_BUILD_NAME]"
echo "MR_BUILD_SOURCE : [$MR_BUILD_SOURCE]"
echo "MR_BUILD_PREFIX : [$MR_BUILD_PREFIX]"
echo "MR_DEFAULT_CFLAGS : [$MR_DEFAULT_CFLAGS]"
echo "MR_ANDROID_NDK_HOME: [$MR_ANDROID_NDK_HOME]"

# 
THIS_DIR=$(DIRNAME=$(dirname "${BASH_SOURCE[0]}"); cd "${DIRNAME}"; pwd)
source "$THIS_DIR/export-android-pkg-config-dir.sh"

echo "PKG_CONFIG_LIBDIR: [$PKG_CONFIG_LIBDIR]"