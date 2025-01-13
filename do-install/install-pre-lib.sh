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
cd "$THIS_DIR"

source ../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_PLAT"
env_assert "XC_WORKSPACE"
env_assert "PRE_COMPILE_TAG"
echo "===check env end==="

function install_plat() {
    local join=""
    
    if [[ "$1" ]];then
        join="-$1"
    fi
    
    export XC_DOWNLOAD_ONAME="$PRE_COMPILE_TAG-$XC_PLAT${join}.zip"
    export XC_DOWNLOAD_URL="https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$PRE_COMPILE_TAG/$LIB_NAME-$XC_PLAT-universal${join}-$VER.zip"
    export XC_UNCOMPRESS_DIR="$XC_WORKSPACE/product/$XC_PLAT/universal${join}"

    ./download-uncompress.sh
}

if test -z $PRE_COMPILE_TAG ;then
    echo "tag can't be nil"
    usage
    exit
fi

# opus-1.3.1-231124151836
LIB_NAME=$(echo $PRE_COMPILE_TAG | awk -F - '{print $1}')
VER=$(echo $PRE_COMPILE_TAG | awk -F - '{print $2}')

if [[ "$XC_PLAT" == 'ios' || "$XC_PLAT" == 'tvos' ]];then
    install_plat
    install_plat "simulator"
else
    install_plat
fi