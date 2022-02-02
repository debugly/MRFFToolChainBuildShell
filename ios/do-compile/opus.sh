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

# cross always
echo "[*] cross compile, on $(uname -m) compile $XC_ARCH."

# prepare build config
OPUS_CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --disable-doc --disable-dependency-tracking --disable-shared"

CC="$XCRUN_CC"
HOST="--host=$XC_ARCH-apple-darwin"
CFLAGS="-arch $XC_ARCH $XC_DEPLOYMENT_TARGET  -isysroot $XCRUN_SDK_PATH"

OPUS_CFG_FLAGS="$OPUS_CFG_FLAGS --with-sysroot=$XCRUN_SDK_PATH"

#----------------------
echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

cd $XC_BUILD_SOURCE

echo "auto generate configure"

./autogen.sh 1>/dev/null

echo 
echo "CC: $CC"
echo "OPUS_CFG_FLAGS: $OPUS_CFG_FLAGS"
echo "CFLAGS: $CFLAGS"
echo 

./configure $OPUS_CFG_FLAGS \
   $HOST \
   CC="$CC" \
   CFLAGS="$CFLAGS" \
   LDFLAGS="$CFLAGS"

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make install -j4 1>/dev/null