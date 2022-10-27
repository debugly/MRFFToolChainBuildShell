#! /usr/bin/env bash
#
# Copyright (C) 2022 Matt Reach<qianlongxu@gmail.com>

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

PLAT=$1
VER=$2

if test -z $VER ;then
    VER='V1.0-104be8c'
fi

set -e

cd $(dirname "$0")
c_dir="$PWD"

function usage() {
    echo " useage:"
    echo " $0 [ios,macos,all]"
}

function download() {
    local plat=$1
    echo "===[download $plat $VER]===================="
    mkdir -p build/pre
    cd build/pre
    echo "https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$VER/$plat-universal-$VER.zip"
    curl -LO https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$VER/$plat-universal-$VER.zip
    mkdir -p ../product/$plat/universal
    unzip -oq $plat-universal-$VER.zip -d ../product/$plat/universal
    tree -L 2 ../product/$plat/universal
    echo "===================================="
    cd - >/dev/null
}

if [[ "$PLAT" == 'ios' || "$PLAT" == 'macos' ]]; then
    download $PLAT
elif [[ "$PLAT" == 'all' ]]; then
    plats="ios macos"
    for plat in $plats; do
        download $plat
    done
else
    usage
fi
