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
source ../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_ARCH"
env_assert "_XC_ARCH"
env_assert "XC_BUILD_NAME"
env_assert "XCRUN_CC"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XCRUN_SDK_PATH"
env_assert "XC_THREAD"
env_assert "XC_PLAT"
echo "XC_DEBUG:$XC_DEBUG"
echo "===check env end==="


toolchain=$PWD/../tools/ios.toolchain.cmake

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "[*] cmake config $cfg"
echo "[*] cmake toolchain $toolchain"
echo "----------------------"

build="${XC_BUILD_SOURCE}/_tmp"

rm -rf "$build"
mkdir -p "$build"

cd "$build"

pf=
if [[ "$XC_PLAT" == 'ios' ]];then
    if [[ $_XC_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64'
    elif [[ $_XC_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR64'
    else
        pf='OS64'
    fi
elif [[ "$XC_PLAT" == 'tvos' ]];then
    if [[ $_XC_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64_TVOS'
    elif [[ $_XC_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR_TVOS'
    else
        pf='TVOS'
    fi
elif [[ "$XC_PLAT" == 'macos' ]];then
    if [[ $_XC_ARCH == 'arm64' ]];then
        pf='MAC_ARM64'
    elif [[ $_XC_ARCH == 'x86_64' ]];then
        pf='MAC'
    fi
fi

cmake -S ${XC_BUILD_SOURCE} -DCMAKE_INSTALL_PREFIX=${XC_BUILD_PREFIX} -GXcode -DBUILD_SHARED_LIBS=0 -DCMAKE_TOOLCHAIN_FILE=$toolchain -DCOMPILE_10BIT=1 -DPLATFORM=$pf

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cmake --build . --target yuv --config Release -- CODE_SIGNING_ALLOWED=NO
cmake --install .