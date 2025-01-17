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

echo "=== [$0] check env begin==="
env_assert "MR_ARCH"
env_assert "_MR_ARCH"
env_assert "MR_BUILD_NAME"
env_assert "MR_CC"
env_assert "MR_DEPLOYMENT_TARGET"
env_assert "MR_BUILD_SOURCE"
env_assert "MR_BUILD_PREFIX"
env_assert "MR_SYS_ROOT"
env_assert "MR_HOST_NPROC"
env_assert "MR_PLAT"
echo "MR_DEBUG:$MR_DEBUG"
echo "===check env end==="


toolchain=$MR_SHELL_TOOLS_DIR/ios.toolchain.cmake

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "[*] cmake config $cfg"
echo "[*] cmake toolchain $toolchain"
echo "----------------------"

build="${MR_BUILD_SOURCE}/_tmp"
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

cmake -S ${MR_BUILD_SOURCE} -DCMAKE_INSTALL_PREFIX=${MR_BUILD_PREFIX} -GXcode -DCMAKE_TOOLCHAIN_FILE=$toolchain -DPLATFORM=$pf -DCOMPILE_10BIT=1 -DBUILD_SHARED_LIBS=0

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cmake --build . --target $LIB_NAME --config Release -- CODE_SIGNING_ALLOWED=NO
cmake --install .
