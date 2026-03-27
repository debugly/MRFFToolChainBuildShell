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
sed -i '' 's/registry = VkXML(ET.parse(xmlfile))/registry = VkXML(ET.parse(xmlfile).getroot())/g' src/vulkan/utils_gen.py

cd "$THIS_DIR"

BUILD_DIR="${MR_BUILD_SOURCE}/meson_build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "----------------------"
echo "[*] configure $LIB_NAME"
echo "----------------------"

# libplacebo uses meson, and we need to specify MoltenVK as Vulkan ICD
# Only enable vulkan backend (no opengl/d3d11)
# Use shaderc for SPIRV compilation

# Find lcms2 and shaderc from our build

# Set deployment target for macOS
export MACOSX_DEPLOYMENT_TARGET=11.0

MESON_OPTS="--buildtype=release \
--prefix=$MR_BUILD_PREFIX \
--default-library=static \
-Dvulkan=enabled \
-Dshaderc=enabled \
-Dglslang=disabled \
-Dopengl=disabled \
-Dd3d11=disabled \
-Dlcms=enabled \
-Dtests=false \
-Dbench=false \
-Ddemos=false \
-Dxxhash=disabled"


# Set up environment for MoltenVK
export VK_ICD_FILENAMES="${MR_BUILD_PREFIX}/share/vulkan/icd.d/MoltenVK_icd.json"

# Disable assertions to fix Xcode SDK compatibility issue
# IMPORTANT: Preserve original CFLAGS which contains -arch parameter
export CFLAGS="${MR_DEFAULT_CFLAGS} -U_LIBCPP_ENABLE_ASSERTIONS"
export CXXFLAGS="${MR_DEFAULT_CFLAGS} -U_LIBCPP_ENABLE_ASSERTIONS"

# Add shaderc and MoltenVK pkgconfig paths
# SHADERC_PC_PATH="${MR_UNI_PROD_DIR}/shaderc/lib/pkgconfig"
# MOLTENVK_PC_PATH="${MR_UNI_PROD_DIR}/MoltenVK/lib/pkgconfig"
# export PKG_CONFIG_PATH="${SHADERC_PC_PATH}:${MOLTENVK_PC_PATH}:${PKG_CONFIG_PATH}"

# # Configure with explicit PKG_CONFIG_LIBDIR to avoid system dependencies
# PKG_CONFIG_LIBDIR="${SHADERC_PC_PATH}:${MOLTENVK_PC_PATH}:$PKG_CONFIG_LIBDIR" \
# PKG_CONFIG_ALLOW_SYSTEM_LIBS=0 \
meson setup ${BUILD_DIR} ${MR_BUILD_SOURCE} ${MESON_OPTS}

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cd "$BUILD_DIR"

meson compile

echo "----------------------"
echo "[*] install $LIB_NAME"
echo "----------------------"

meson install
