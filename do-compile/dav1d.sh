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

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"
source ../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_ARCH"
env_assert "XC_BUILD_NAME"
env_assert "XCRUN_CC"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XCRUN_SDK_PATH"
env_assert "XC_THREAD"
echo "XC_DEBUG:$XC_DEBUG"
echo "XC_IS_SIMULATOR:$XC_IS_SIMULATOR"
echo "===check env end==="

# prepare build config
CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --default-library static"

if [[ "$BUILD_OPT" == "debug" ]]; then
    CFG_FLAGS="$CFG_FLAGS --buildtype=debug"
else
    CFG_FLAGS="$CFG_FLAGS --buildtype=release"
fi

cd $XC_BUILD_SOURCE
export CC="$XCRUN_CC"
export CXX="$XCRUN_CXX"

if [[ $(uname -m) != "$XC_ARCH" || "$XC_FORCE_CROSS" ]]; then
    if [[ $XC_IS_SIMULATOR != 1 ]]; then
        echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH."
        CFG_FLAGS="$CFG_FLAGS --cross-file $THIS_DIR/../configs/meson-crossfiles/$XC_ARCH-$XC_PLAT.meson"
    else
        echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH simulator."
        CFG_FLAGS="$CFG_FLAGS --cross-file $THIS_DIR/../configs/meson-crossfiles/$XC_ARCH-$XC_PLAT-simulator.meson"
    fi
fi

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "CC: $XCRUN_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "----------------------"
echo

build=./build-$XC_ARCH
if [[ -d $build ]]; then
    rm -rf $build
fi

meson setup $build $CFG_FLAGS >/dev/null

cd $build

meson compile && meson install

# ninja -C build
# ninja -C build install
