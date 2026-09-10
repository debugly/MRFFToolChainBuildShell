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
echo "[*] init submodules for $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE
git submodule update --init --recursive

# Fix Python 3.14 compatibility issue in utils_gen.py
# ET.parse() returns ElementTree, need to call .getroot() to get Element
if [[ -f src/vulkan/utils_gen.py ]]; then
    sed -i '' 's/registry = VkXML(ET.parse(xmlfile))/registry = VkXML(ET.parse(xmlfile).getroot())/g' src/vulkan/utils_gen.py || true
fi

cd "$THIS_DIR"

# Disable assertions to fix Xcode SDK compatibility issue
# IMPORTANT: Preserve original CFLAGS which contains -arch parameter
export CFLAGS="${MR_DEFAULT_CFLAGS} -U_LIBCPP_ENABLE_ASSERTIONS"
export CXXFLAGS="${MR_DEFAULT_CFLAGS} -U_LIBCPP_ENABLE_ASSERTIONS"

MESON_OPTS="-Dvulkan=enabled \
-Dshaderc=enabled \
-Dglslang=disabled \
-Dopengl=disabled \
-Dd3d11=disabled \
-Dlcms=enabled \
-Ddovi=enabled \
-Dtests=false \
-Dbench=false \
-Ddemos=false \
-Dxxhash=disabled"

./meson-compatible.sh "$MESON_OPTS"