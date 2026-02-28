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

function check_lib()
{
    local lib=$1
    pkg-config --libs $lib --silence-errors >/dev/null || not_found=$?

    if [[ $not_found -eq 0 ]];then
        echo "[✅] $lib : $(pkg-config --modversion $lib)" #, $(pkg-config --cflags $lib)
    else
        echo "[❌] $lib not found!"
    fi
}

echo "--check denpendencies--------------------"
check_lib 'freetype2'
check_lib 'fribidi'
check_lib 'harfbuzz'
check_lib 'libunibreak'
check_lib 'fontconfig'
echo "----------------------"

./meson-compatible.sh "-Dtest=disabled -Dprofile=disabled -Dfontconfig=enabled -Dcoretext=disabled -Dasm=disabled -Dlibunibreak=enabled"
