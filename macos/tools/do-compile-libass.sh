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
LIBASS_CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --includedir=$XC_BUILD_PREFIX/include/libass"
LIBASS_CFG_FLAGS="$LIBASS_CFG_FLAGS --disable-dependency-tracking --disable-fontconfig"

CFLAG="-arch $XC_ARCH -mmacosx-version-min=$XC_DEPLOYMENT_TARGET"
CC="$XCRUN_CC"

# cross
if [[ $(uname -m) != "$XC_ARCH" ]];then
    echo "[*] cross compile, on $(uname -m) compile $XC_ARCH."
    HOST="--host=$XC_ARCH-apple-darwin"
    CFLAG="$CFLAG -isysroot $XCRUN_SDK_PATH"
fi

#--------------------
echo "\n--------------------"
echo "[*] configurate $LIB_NAME"
echo "--------------------"

if [ ! -d $XC_BUILD_SOURCE ]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find $XC_BUILD_SOURCE directory for $XC_BUILD_NAME"
    echo "!! Run 'init-*.sh' first"
    echo ""
    exit 1
fi

cd $XC_BUILD_SOURCE
# Makefile already in git,so configure everytime compile
echo "CC: $CC"
echo "CFLAG: $CFLAG"
echo "CFG: $LIBASS_CFG_FLAGS"
echo 

autoreconf -i

export CFLAGS="$CFLAG -I/opt/homebrew/opt/icu4c/include"
export LDFLAGS="$CFLAG -L/opt/homebrew/opt/icu4c/lib"
export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include"

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/opt/icu4c/lib/pkgconfig"

./configure $LIBASS_CFG_FLAGS


#--------------------
echo "\n--------------------"
echo "[*] compile $LIB_NAME"
echo "--------------------"

make install -j4
