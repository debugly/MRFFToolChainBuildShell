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
# https://stackoverflow.com/questions/6003374/what-is-cmake-equivalent-of-configure-prefix-dir-make-all-install
# https://cmake.org/cmake/help/v3.28/variable/CMAKE_OSX_SYSROOT.html
# https://cmake.org/cmake/help/v3.14/manual/cmake-toolchains.7.html#switching-between-device-and-simulator
# https://stackoverflow.com/questions/27660048/cmake-check-if-mac-os-x-use-apple-or-apple


set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"
CMAKE_OTHER_FLAGS="$1"

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "[*] other cmake flags: $CMAKE_OTHER_FLAGS"
echo "----------------------"

build="${MR_BUILD_SOURCE}/camke_wksp"

rm -rf "$build"
mkdir -p "$build"
cd "$build"

pf=
if [[ "$MR_PLAT" == 'ios' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR64'
    else
        pf='OS64'
    fi
elif [[ "$MR_PLAT" == 'tvos' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64_TVOS'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR_TVOS'
    else
        pf='TVOS'
    fi
elif [[ "$MR_PLAT" == 'macos' ]];then
    if [[ $_MR_ARCH == 'arm64' ]];then
        pf='MAC_ARM64'
    elif [[ $_MR_ARCH == 'x86_64' ]];then
        pf='MAC'
    fi
fi

cmake -S ${MR_BUILD_SOURCE} \
    -DCMAKE_INSTALL_PREFIX=${MR_BUILD_PREFIX} \
    -DCMAKE_TOOLCHAIN_FILE="${MR_SHELL_TOOLS_DIR}/ios.toolchain.cmake" \
    -DPLATFORM=$pf \
    ${CMAKE_OTHER_FLAGS} \
    -GXcode

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cmake --build . --target $CMAKE_TARGET_NAME --config Release -- CODE_SIGNING_ALLOWED=NO
cmake --install .