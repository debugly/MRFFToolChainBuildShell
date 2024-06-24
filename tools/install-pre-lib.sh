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

set -e

PLAT=$1
TAG=$2

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"
cd ../

function usage() {
    echo "=== useage ===================="
    echo "Download precompiled libs from github,The usage is as follows:"
    echo "$0 [ios|macos|tvos|all] [<release tag>]"
}

function download_arch() {
    local plat=$1
    local join=$2

    if [[ "$join" ]];then
        join="-$join"
    else
        join=""
    fi

    JOIN="$join"
    ONAME="build/pre/${TAG}-${plat}${join}.zip"
    if [[ -f "$ONAME" ]];then
        echo "$ONAME already exist,no need download."
        return
    fi
    
    local fname="$LIB_NAME-$plat-universal${join}-$VER.zip"
    local url="https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$TAG/$fname"
    
    echo "---[download $fname]-----------------"
    echo "$url"
    mkdir -p build/pre
    local tname="build/pre/${TAG}${join}.tmp"
    curl -L "$url" -o "$tname"
    if [[ $? -eq 0 ]];then
        mv "$tname" "$ONAME"
    fi
}

function extract(){
    local plat=$1
    if [[ -f "$ONAME" ]];then
        PRODUCT_DIR="build/product/$plat/universal${JOIN}"
        mkdir -p "$PRODUCT_DIR"
        unzip -oq "$ONAME" -d "$PRODUCT_DIR"
        echo "extract zip file"
    else
        echo "you need download ${ONAME} firstly."
        exit 1
    fi
}

function install() {
    local plat=$1
    if [[ "$plat" == 'ios' || "$plat" == 'tvos' ]];then
        download_arch "$plat"
        extract "$plat"
        download_arch "$plat" "simulator"
        extract "$plat"
    else
        download_arch "$plat"
        extract "$plat"
    fi
}

if [[ "$PLAT" != 'ios' && "$PLAT" != 'macos' && "$PLAT" != 'tvos' && "$PLAT" != 'all' ]]; then
    echo 'plat must use ios or macos or tvos'
    usage
    exit
fi

if test -z $TAG ;then
    echo "tag can't be nil"
    usage
    exit
fi

# opus-1.3.1-231124151836
LIB_NAME=$(echo $TAG | awk -F - '{print $1}')
VER=$(echo $TAG | awk -F - '{print $2}')

if [[ "$PLAT" == 'ios' || "$PLAT" == 'macos' || "$PLAT" == 'tvos' ]]; then
    install $PLAT
elif [[ "$PLAT" == 'all' ]]; then
    plats="ios macos tvos"
    for plat in $plats; do
        install $plat
    done
else
    usage
fi
