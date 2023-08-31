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
env_assert "XCRUN_CC"
echo "XC_OPTS:$XC_OPTS"
echo "===check env end==="

# prepare build config
DAV1D_CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --default-library static"

if [[ "$BUILD_OPT" == "debug" ]]; then
    DAV1D_CFG_FLAGS="$DAV1D_CFG_FLAGS --buildtype=debug"
else
    DAV1D_CFG_FLAGS="$DAV1D_CFG_FLAGS --buildtype=release"
fi

cd $XC_BUILD_SOURCE
export CC="$XCRUN_CC"
export CXX="$XCRUN_CXX"

if [[ $(uname -m) != "$XC_ARCH" || "$XC_FORCE_CROSS" ]]; then
   echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH."

   DAV1D_CFG_FLAGS="$DAV1D_CFG_FLAGS --cross-file package/crossfiles/$XC_ARCH-$XC_PLAT.meson"
fi

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "CC: $XCRUN_CC"
echo "DAV1D_CFG_FLAGS: $DAV1D_CFG_FLAGS"
echo "----------------------"
echo

if [[ -d build ]]; then
   rm -rf build
fi

meson setup build $DAV1D_CFG_FLAGS >/dev/null

cd ./build

meson compile && meson install

# ninja -C build
# ninja -C build install
