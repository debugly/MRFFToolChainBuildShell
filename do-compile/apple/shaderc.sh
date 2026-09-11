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
extra_tp="${MR_WORKSPACE}/extra/shaderc/third_party"
if [ ! -d "$MR_BUILD_SOURCE/third_party/spirv-tools" ]; then
    if [ -d "$extra_tp/spirv-tools" ]; then
        echo "[*] copy third_party from $extra_tp..."
        mkdir -p "$MR_BUILD_SOURCE/third_party"
        cp -R "$extra_tp/"* "$MR_BUILD_SOURCE/third_party/"
    elif [ -f "./utils/git-sync-deps" ]; then
        echo "running git-sync-deps..."
        chmod +x ./utils/git-sync-deps
        ./utils/git-sync-deps
        if [ -d "$MR_BUILD_SOURCE/third_party/spirv-tools" ]; then
            echo "[*] save third_party cache to $extra_tp..."
            mkdir -p "$extra_tp"
            cp -R "$MR_BUILD_SOURCE/third_party/"* "$extra_tp/"
        fi
    else
        echo "git-sync-deps not found"
        exit 1
    fi
fi

cd "$THIS_DIR"

if [[ "$MR_PLAT" == 'ios' || "$MR_PLAT" == 'tvos' ]]; then
    export MR_DEPLOYMENT_TARGET_VER=13.0
elif [[ "$MR_PLAT" == 'macos' ]]; then
    export MR_DEPLOYMENT_TARGET_VER=11.0
fi

export CMAKE_GENERATOR=Ninja

CMAKE_OPTS="-DSHADERC_SKIP_TESTS=ON \
    -DSHADERC_SKIP_EXAMPLES=ON \
    -DSHADERC_SKIP_EXECUTABLES=ON \
    -DSHADERC_SKIP_COPYRIGHT_CHECK=ON \
    -DCMAKE_MACOSX_BUNDLE=OFF"

./cmake-compatible.sh "$CMAKE_OPTS"

# clean up other unused pkgconfig files, keep shaderc.pc and shaderc_static.pc
rm -f ${MR_BUILD_PREFIX}/lib/pkgconfig/SPIRV-Tools-shared.pc
rm -f ${MR_BUILD_PREFIX}/lib/pkgconfig/SPIRV-Tools.pc