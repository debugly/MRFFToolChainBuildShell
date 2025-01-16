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
#https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script

case $_MR_ARCH in
    *v7a)
    export MR_TRIPLE=armv7a-linux-androideabi$MR_ANDROID_API
    ;;
    x86)
    export MR_TRIPLE=i686-linux-android$MR_ANDROID_API
    ;;
    x86_64)
    export MR_TRIPLE=x86_64-linux-android$MR_ANDROID_API
    ;;
    arm64*)
    export MR_TRIPLE=aarch64-linux-android$MR_ANDROID_API
    ;;
    *)
    echo "unknown architecture $_MR_ARCH";
    exit 1
    ;;
esac

# x86_64
export MR_ARCH="$_MR_ARCH"
# openssl-armv7a
export MR_BUILD_NAME="${LIB_NAME}-${_MR_ARCH}"
# ios/ffmpeg-x86_64
export MR_BUILD_SOURCE="${MR_SRC_ROOT}/${MR_BUILD_NAME}"
# ios/ffmpeg-x86_64
export MR_BUILD_PREFIX="${MR_PRODUCT_ROOT}/${MR_BUILD_NAME}"

if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "You must define ANDROID_NDK_HOME before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
else
    export MR_NDK_REL=$(grep -o '^## r[0-9]*.*' $ANDROID_NDK_HOME/CHANGELOG.md | awk '{print $2}')
    echo "NDK$MR_NDK_REL detected"
fi

# find clang from NDK toolchain
export XCRUN_CC="clang"
export XCRUN_CXX="clang++"
export MR_ANDROID_API=21

toolchian="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${MR_HOST_TAG}/bin"
export PATH="$toolchian:$PATH"

alias ar=llvm-ar
alias as=llvm-as
alias ranlib=llvm-ranlib
alias strip=llvm-strip

echo "MR_ARCH        : [$MR_ARCH]"
echo "MR_TRIPLE      : [$MR_TRIPLE]"
echo "MR_ANDROID_API : [$MR_ANDROID_API]"
echo "MR_BUILD_NAME  : [$MR_BUILD_NAME]"
echo "MR_BUILD_SOURCE: [$MR_BUILD_SOURCE]"
echo "MR_BUILD_PREFIX: [$MR_BUILD_PREFIX]"
echo "MR_ANDROID_NDK_TOOLCHAIN: [$toolchian]"