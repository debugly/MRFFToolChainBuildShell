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

echo "=== [$0] check env begin==="
env_assert "MR_ARCH"
env_assert "MR_BUILD_NAME"
env_assert "MR_CC"
env_assert "MR_DEPLOYMENT_TARGET"
env_assert "MR_BUILD_SOURCE"
env_assert "MR_BUILD_PREFIX"
env_assert "MR_SYS_ROOT"
env_assert "MR_HOST_NPROC"
echo "MR_DEBUG:$MR_DEBUG"
echo "===check env end==="

# prepare build config
CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --default-library static -Dpng=disabled -Dharfbuzz=disabled"

if [[ "$BUILD_OPT" == "debug" ]]; then
    CFG_FLAGS="$CFG_FLAGS --buildtype=debug"
else
    CFG_FLAGS="$CFG_FLAGS --buildtype=release"
fi

cd $MR_BUILD_SOURCE
export CC="$MR_CC"
export CXX="$MR_CXX"

if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]]; then
    if [[ $MR_IS_SIMULATOR != 1 ]]; then
        echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
        CFG_FLAGS="$CFG_FLAGS --cross-file $MR_SHELL_CONFIGS_DIR/meson-crossfiles/$MR_ARCH-$MR_PLAT.meson"
    else
        echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH simulator."
        CFG_FLAGS="$CFG_FLAGS --cross-file $MR_SHELL_CONFIGS_DIR/meson-crossfiles/$MR_ARCH-$MR_PLAT-simulator.meson"
    fi
fi

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "CC: $MR_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "----------------------"
echo

build=./build-$MR_ARCH
if [[ -d $build ]]; then
    rm -rf $build
fi

meson setup $build $CFG_FLAGS

#cat $MR_BUILD_SOURCE/build-$MR_ARCH/meson-logs/meson-log.txt

cd $build

echo "compile"

meson compile && meson install

# ninja -C build
# ninja -C build install
