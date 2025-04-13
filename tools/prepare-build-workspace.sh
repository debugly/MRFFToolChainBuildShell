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

# Using Native CMake
export MR_CMAKE_EXECUTABLE=$(which cmake)
# Using Build machine's Ninja. It is used for libdav1d building. Needs to be installed
export MR_NINJA_EXECUTABLE=$(which ninja)
# Meson is used for libdav1d building. Needs to be installed
export MR_MESON_EXECUTABLE=$(which meson)
# Nasm is used for libdav1d and libx264 building. Needs to be installed
export MR_NASM_EXECUTABLE=$(which nasm)
# A utility to properly pick shared libraries by FFmpeg's configure script. Needs to be installed
export MR_PKG_CONFIG_EXECUTABLE=$(which pkg-config)
#on intel compile arm64 harfbuzz can't find pkg-config
export PKG_CONFIG=$(which pkg-config)

if [[ -z "$MR_WORKSPACE" ]];then
    THIS_DIR=$(DIRNAME=$(dirname "${BASH_SOURCE[0]}"); cd "${DIRNAME}/../"; pwd)
    export MR_WORKSPACE="${THIS_DIR}/build"
fi

export MR_SRC_ROOT="${MR_WORKSPACE}/src/${MR_PLAT}"
export MR_PRODUCT_ROOT="${MR_WORKSPACE}/product/${MR_PLAT}"
export MR_XCFRMK_DIR="${MR_WORKSPACE}/product/xcframework"
export MR_IOS_PRODUCT_ROOT="${MR_WORKSPACE}/product/ios"
export MR_MACOS_PRODUCT_ROOT="${MR_WORKSPACE}/product/macos"
export MR_TVOS_PRODUCT_ROOT="${MR_WORKSPACE}/product/tvos"
export MR_UNI_PROD_DIR="${MR_PRODUCT_ROOT}/universal"
export MR_UNI_SIM_PROD_DIR="${MR_PRODUCT_ROOT}/universal-simulator"


echo "MR_SRC_ROOT    : [$MR_SRC_ROOT]"
echo "MR_PRODUCT_ROOT: [$MR_PRODUCT_ROOT]"
echo "MR_UNI_PROD_DIR: [$MR_UNI_PROD_DIR]"
echo "MR_UNI_SIM_PROD_DIR: [$MR_UNI_SIM_PROD_DIR]"
