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

# can't use cmake,because ios undeclared function 'getentropy'
# https://gitlab.gnome.org/GNOME/libxml2/-/issues/774#note_2174500
# ./cmake-compatible.sh "-DBUILD_SHARED_LIBS=0 -DLIBXML2_WITH_PROGRAMS=0 -DLIBXML2_WITH_ZLIB=1 -DLIBXML2_WITH_PYTHON=0 -DLIBXML2_WITH_ICONV=1"


set -e

CFG_FLAGS="-Ddocs=disabled -Ddebugging=disabled -Dpython=disabled -Dzlib=enabled"

./meson-compatible.sh "$CFG_FLAGS"