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

function download() {
    local oname="build/pre/${PRE_COMPILE_TAG}.xcf"
    if [[ -f "$oname" ]];then
        echo "$oname already exist,no need download."
        return
    fi
    
    local fname="$LIB_NAME-apple-xcframework-$VER.zip"
    local url="https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$PRE_COMPILE_TAG/$fname"
    
    echo "---[download $fname]-----------------"
    echo "$url"
    mkdir -p build/pre
    local tname="build/pre/${PRE_COMPILE_TAG}.tmp"
    curl -L "$url" -o "$tname"
    if [[ $? -eq 0 ]];then
        mv "$tname" "$oname"
    fi
}

function extract(){
    local oname="build/pre/${PRE_COMPILE_TAG}.xcf"
    
    if [[ -f "$oname" ]];then
        mkdir -p build/product/xcframework
        unzip -oq "$oname" -d build/product/xcframework
        echo "extract zip file"
        if command -v tree >/dev/null 2>&1; then
            tree -L 2 build/product/xcframework
        fi
    else
        echo "you need download ${oname} firstly."
        exit 1
    fi
}

function install(){
    download
    extract
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