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

# This script is based on projects below
# https://github.com/bilibili/ijkplayer
# https://github.com/openssl/openssl/blob/master/NOTES-ANDROID.md
# https://github.com/xbmc/xbmc/pull/25092/commits/494a452cd65abe1447771874cc79ed967015d944

# no-deprecated, fix ffmepg compile error:
# libavformat/tls_openssl.c:56:16: error: use of undeclared identifier 'CRYPTO_LOCK'; did you mean 'CRYPTO_free'?
#     if (mode & CRYPTO_LOCK)
#                ^~~~~~~~~~~
#                CRYPTO_free

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

case $_MR_ARCH in
    armv7a)
    os=android-arm
    ;;
    x86)
    os=android-x86
    ;;
    x86_64)
    os=android-x86_64
    ;;
    arm64)
    os=android-arm64
    ;;
    *)
    echo "unknown architecture $_MR_ARCH";
    exit 1
    ;;
esac

CFG_FLAGS="no-shared no-engine no-apps no-dynamic-engine no-static-engine \
        no-dso no-ui-console no-tests \
        --prefix=$MR_BUILD_PREFIX \
        --openssldir=$MR_BUILD_PREFIX \
        -U__ANDROID_API__ -D__ANDROID_API__=$MR_ANDROID_API \
        $os"

if [[ "$MR_DEBUG" != "debug" ]]; then
    CFG_FLAGS="$CFG_FLAGS --release"
fi

# -arch $MR_ARCH
C_FLAGS="$MR_DEFAULT_CFLAGS"

cd $MR_BUILD_SOURCE

if [ -f "./Makefile" ]; then
    echo 'reuse configure'
    echo "----------------------"
    echo "[*] reuse configurate"
else
    echo "----------------------"
    echo "[*] configurate"
    echo "C_FLAGS: $C_FLAGS"
    echo "Openssl CFG: $CFG_FLAGS"
    echo "----------------------"

    export C_FLAGS="$C_FLAGS"
    export CXXFLAG="$C_FLAGS"
    export CC="$MR_TRIPLE_CC"
    export AR="$MR_AR"
    export AS="$MR_AS"
    export RANLIB="$MR_RANLIB"
    export STRIP="$MR_STRIP"
    export ANDROID_NDK_ROOT="$MR_ANDROID_NDK_HOME"

    ./Configure $CFG_FLAGS
fi

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make build_libs -j$MR_HOST_NPROC >/dev/null
make install_dev >/dev/null