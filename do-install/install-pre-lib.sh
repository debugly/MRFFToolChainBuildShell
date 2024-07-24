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

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR/.."

function download_plat() {
    local plat=$1
    local join=$2
    
    if [[ "$join" ]];then
        join="-$join"
    else
        join=""
    fi
    
    JOIN="$join"
    ONAME="build/pre/${PRE_COMPILE_TAG}-${plat}${join}.zip"
    if [[ -f "$ONAME" ]];then
        echo "$ONAME already exist,no need download."
        return
    fi
    
    local fname="$LIB_NAME-$plat-universal${join}-$VER.zip"
    local url="https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$PRE_COMPILE_TAG/$fname"
    
    echo "---[download $fname]-----------------"
    echo "$url"
    mkdir -p build/pre
    local tname="build/pre/${PRE_COMPILE_TAG}${join}.tmp"
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
    local plat=$XC_PLAT
    if [[ "$plat" == 'ios' || "$plat" == 'tvos' ]];then
        download_plat "$plat"
        extract "$plat"
        download_plat "$plat" "simulator"
        extract "$plat"
    else
        download_plat "$plat"
        extract "$plat"
    fi
}

if test -z $PRE_COMPILE_TAG ;then
    echo "tag can't be nil"
    usage
    exit
fi

# opus-1.3.1-231124151836
LIB_NAME=$(echo $PRE_COMPILE_TAG | awk -F - '{print $1}')
VER=$(echo $PRE_COMPILE_TAG | awk -F - '{print $2}')

install
