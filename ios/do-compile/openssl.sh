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
# https://wiki.openssl.org/index.php/Compilation_and_Installation#OS_X

set -e

TOOLS=$(dirname "$0")
source $TOOLS/../../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_ARCH"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XC_BUILD_NAME"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XCRUN_SDK_PATH"
echo "ARGV:$*"
echo "===check env end==="

# prepare build config
OPENSSL_CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --openssldir=$XC_BUILD_PREFIX"

if [ "$XC_ARCH" = "x86_64" ]; then
    OPENSSL_CFG_FLAGS="$OPENSSL_CFG_FLAGS darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
elif [ "$XC_ARCH" = "arm64" ]; then
    OPENSSL_CFG_FLAGS="$OPENSSL_CFG_FLAGS darwin64-arm64-cc enable-ec_nistp_64_gcc_128"
else
    echo "unknown architecture $FF_ARCH";
    exit 1
fi

OPENSSL_CFG_FLAGS="$OPENSSL_CFG_FLAGS no-shared no-hw no-engine no-asm"

export CC="$XCRUN_CC"
export CFLAG="-arch $XC_ARCH $XC_DEPLOYMENT_TARGET -isysroot $XCRUN_SDK_PATH"
export CXXFLAG="$CFLAG"

#--------------------
echo "\n--------------------"
echo "[*] configurate $LIB_NAME"
echo "--------------------"

cd $XC_BUILD_SOURCE
if [ -f "./Makefile" ]; then
    echo 'reuse configure'
else
    echo 
    echo "CC: $CC"
    echo "CFLAG: $CFLAG"
    echo "CFG: $OPENSSL_CFG_FLAGS"
    echo 
    ./Configure \
        $OPENSSL_CFG_FLAGS
    make clean
fi

#--------------------
echo "\n--------------------"
echo "[*] compile $LIB_NAME"
echo "--------------------"
set +e
make
make install_sw
