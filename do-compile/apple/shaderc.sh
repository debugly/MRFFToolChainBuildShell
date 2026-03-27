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

echo "----------------------"
echo "[*] sync dependencies for $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE
if [ -f "./utils/git-sync-deps" ]; then
    echo "running git-sync-deps..."
    chmod +x ./utils/git-sync-deps
    ./utils/git-sync-deps
else
    echo "git-sync-deps not found"
    exit 1
fi

cd "$THIS_DIR"

pf=
if [[ "$MR_PLAT" == 'ios' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR64'
    else
        pf='OS64'
    fi
    export MR_DEPLOYMENT_TARGET_VER=13.0
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
    # glslang requires macOS 10.15+ for std::filesystem
    export MR_DEPLOYMENT_TARGET_VER=11.0
fi

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

build="${MR_BUILD_SOURCE}/cmake_wksp"
rm -rf "$build"
mkdir -p "$build"
cd "$build"

cmake -S ${MR_BUILD_SOURCE} \
    -DCMAKE_PREFIX_PATH=${PKG_CONFIG_LIBDIR} \
    -DCMAKE_INSTALL_PREFIX=${MR_BUILD_PREFIX} \
    -DCMAKE_TOOLCHAIN_FILE="${MR_SHELL_TOOLS_DIR}/ios.toolchain.cmake" \
    -DPLATFORM=$pf \
    -DDEPLOYMENT_TARGET=$MR_DEPLOYMENT_TARGET_VER \
    -DCMAKE_BUILD_TYPE=Release \
    -DSHADERC_SKIP_TESTS=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_MACOSX_BUNDLE=OFF \
    -GNinja

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cmake --build . --config Release --parallel

echo "----------------------"
echo "[*] install $LIB_NAME"
echo "----------------------"

cmake --install .

# clean up pkgconfig files
rm -f ${MR_BUILD_PREFIX}/lib/pkgconfig/SPIRV-Tools-shared.pc
rm -f ${MR_BUILD_PREFIX}/lib/pkgconfig/SPIRV-Tools.pc
rm -f ${MR_BUILD_PREFIX}/lib/pkgconfig/shaderc.pc
rm -f ${MR_BUILD_PREFIX}/lib/pkgconfig/shaderc_static.pc