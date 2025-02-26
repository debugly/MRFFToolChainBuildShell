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

function install_plat() {
    
    export MR_DOWNLOAD_ONAME="$PRE_COMPILE_TAG-xcfmwk.zip"
    export MR_DOWNLOAD_URL="https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$PRE_COMPILE_TAG/$LIB_NAME-apple-xcframework-$VER.zip"
    export MR_UNCOMPRESS_DIR="$MR_XCFRMK_DIR"

    ./download-uncompress.sh
}

install_plat