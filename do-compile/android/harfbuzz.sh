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
# https://github.com/harfbuzz/harfbuzz/blob/main/BUILD.md

# https://trac.macports.org/ticket/60987

set -e

CFG_FLAGS="-Ddocs=disabled -Dcairo=disabled -Dchafa=disabled -Dtests=disabled"

echo "----------------------"
echo "[*] check freetype"

pkg-config --libs freetype2 --silence-errors >/dev/null && enable_freetype2=1

if [[ $enable_freetype2 ]];then
    echo "[*] --enable-freetype"
    CFG_FLAGS="$CFG_FLAGS -Dfreetype=enabled"
else
    echo "[*] --disable-freetype"
    CFG_FLAGS="$CFG_FLAGS -Dfreetype=disabled"
fi

./meson-compatible.sh "$CFG_FLAGS"