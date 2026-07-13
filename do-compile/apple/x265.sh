#!/usr/bin/env bash
#
# Copyright (C) 2021 Matt Reach<qianlongxu@gmail.com>
#
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

build="${MR_BUILD_SOURCE}/cmake_wksp"

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

CMAKE_OTHER_OPTS="-DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DENABLE_LIBNUMA=OFF"

if [[ "$MR_IS_SIMULATOR" == "1" ]]; then
    CMAKE_OTHER_OPTS="$CMAKE_OTHER_OPTS -DENABLE_ASSEMBLY=OFF"
fi

cfg_type="Release"
if [[ "$MR_DEBUG" == "debug" ]];then
    cfg_type="Debug"
fi

cmake -S "${MR_BUILD_SOURCE}/source" \
    -DCMAKE_INSTALL_PREFIX=${MR_BUILD_PREFIX} \
    -DCMAKE_TOOLCHAIN_FILE="${MR_SHELL_TOOLS_DIR}/ios.toolchain.cmake" \
    -DPLATFORM=$pf \
    -DDEPLOYMENT_TARGET=$MR_DEPLOYMENT_TARGET_VER \
    -DCMAKE_BUILD_TYPE=$cfg_type \
    ${CMAKE_OTHER_OPTS} \
    -G "Unix Makefiles"

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cmake --build . -j$MR_HOST_NPROC

cmake --install .

if [[ -f "$MR_BUILD_PREFIX/lib/pkgconfig/x265.pc" ]]; then
    echo "[*] Appending -lc++ to Libs.private in x265.pc"
    sed -i "" 's/Libs.private: \(.*\)/Libs.private: \1 -lc++/' "$MR_BUILD_PREFIX/lib/pkgconfig/x265.pc"
fi
