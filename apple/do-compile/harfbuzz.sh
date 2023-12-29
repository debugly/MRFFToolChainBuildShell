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

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
source $THIS_DIR/../../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_ARCH"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XC_BUILD_NAME"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XCRUN_SDK_PATH"
env_assert "XCRUN_CC"
echo "XC_OPTS:$XC_OPTS"
echo "===check env end==="

# prepare build config
CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --default-library static"

if [[ "$BUILD_OPT" == "debug" ]]; then
    CFG_FLAGS="$CFG_FLAGS --buildtype=debug"
else
    CFG_FLAGS="$CFG_FLAGS --buildtype=release"
fi

MY_PKG_CONFIG_LIBDIR=''
# with freetype
if [[ -f "${XC_PRODUCT_ROOT}/freetype-$XC_ARCH/lib/pkgconfig/freetype2.pc" || -f "${XC_PRODUCT_ROOT}/universal/freetype/lib/pkgconfig/freetype2.pc" ]]; then
    echo "[*] --enable-freetype"
    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    
    if [[ -f "${XC_PRODUCT_ROOT}/freetype-$XC_ARCH/lib/pkgconfig/freetype2.pc" ]]; then
        MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/freetype-$XC_ARCH/lib/pkgconfig"
    else
        MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/universal/freetype/lib/pkgconfig"
    fi
else
    echo "[*] --disable-freetype"
fi

if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
    export PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR"
fi

cd $XC_BUILD_SOURCE
export CC="$XCRUN_CC"
export CXX="$XCRUN_CXX"

if [[ $(uname -m) != "$XC_ARCH" || "$XC_FORCE_CROSS" ]]; then
   echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH."
   CFG_FLAGS="$CFG_FLAGS --cross-file $THIS_DIR/../compile-cfgs/meson-crossfiles/$XC_ARCH-$XC_PLAT.meson"
   export PKG_CONFIG=$(which pkg-config)
fi

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "CC: $XCRUN_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "PKG_CONFIG_LIBDIR: $MY_PKG_CONFIG_LIBDIR"
echo "----------------------"
echo

build=./build-$XC_ARCH
if [[ -d $build ]]; then
   rm -rf $build
fi

meson setup $build $CFG_FLAGS 1>/dev/null

cd $build
# show all configure
# https://mesonbuild.com/Build-options.html
# meson configure
meson configure -Ddocs=disabled -Dcairo=disabled -Dchafa=disabled -Dfreetype=enabled -Dtests=disabled
meson compile
meson install 1>/dev/null