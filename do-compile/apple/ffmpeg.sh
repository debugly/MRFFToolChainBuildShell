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

# This script is based on projects below
# https://github.com/bilibili/ijkplayer

set -e

error_handler() {
    echo "An error occurred!"
    tail -n20 ${MR_BUILD_SOURCE}/ffbuild/config.log
}

trap 'error_handler' ERR

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

# ffmpeg config options
source $MR_SHELL_CONFIGS_DIR/ffconfig/module-full.sh
source $MR_SHELL_CONFIGS_DIR/ffconfig/auto-detect-third-libs.sh

CFG_FLAGS=
CFG_FLAGS="$CFG_FLAGS $COMMON_FF_CFG_FLAGS"
CFG_FLAGS="$CFG_FLAGS $THIRD_CFG_FLAGS"

C_FLAGS="$MR_DEFAULT_CFLAGS"
EXTRA_LDFLAGS=
LDFLAGS="$C_FLAGS $EXTRA_LDFLAGS"
# C_FLAGS="$C_FLAGS -I/Users/matt/GitWorkspace/MoltenVK/Package/Release/MoltenVK/include"
# use system xml2 lib
# C_FLAGS="$C_FLAGS $(xml2-config --prefix=${MR_SYS_ROOT}/usr --cflags)"
# LDFLAGS="$C_FLAGS $(xml2-config --prefix=${MR_SYS_ROOT}/usr --libs)"

# LDFLAGS="$LDFLAGS -framework IOKit -framework Metal -framework IOSurface -framework CoreGraphics -framework QuartzCore -framework AppKit -framework Foundation -lc++ /Users/matt/GitWorkspace/MoltenVK/Package/Release/MoltenVK/static/MoltenVK.xcframework/macos-arm64_x86_64/libMoltenVK.a"
echo "----------------------"
echo "[*] configure"

if [[ ! -d $MR_BUILD_SOURCE ]]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find lib source: $MR_BUILD_SOURCE"
    echo "!! Run 'init-*.sh' first"
    echo ""
    exit 1
fi

cd $MR_BUILD_SOURCE
if [[ -f "./config.h" ]]; then
    echo 'reuse configure'
else
    echo
    echo "CC: $MR_CC"
    echo "CFLAGS: $C_FLAGS"
    echo "LDFLAG:$LDFLAGS"
    echo "FF_CFG_FLAGS: $CFG_FLAGS"
    echo
    ./configure \
        $CFG_FLAGS \
        --cc="$MR_CC" \
        --as="perl ${MR_GAS_PERL} -arch ${MR_ARCH} -- $MR_CC" \
        --extra-cflags="$C_FLAGS" \
        --extra-cxxflags="$C_FLAGS" \
        --extra-ldflags="$LDFLAGS"
fi

#----------------------
echo "----------------------"
echo "[*] compile"

make -j$MR_HOST_NPROC >/dev/null

cp config.* $MR_BUILD_PREFIX
make install >/dev/null
mkdir -p $MR_BUILD_PREFIX/include/libffmpeg
cp -f config.h $MR_BUILD_PREFIX/include/libffmpeg/
cp -f config_components.h $MR_BUILD_PREFIX/include/libffmpeg/ &> /dev/null || true
# copy private header for ffmpeg-kit.
cp -f $MR_BUILD_SOURCE/libavutil/getenv_utf8.h $MR_BUILD_PREFIX/include/libavutil/ &> /dev/null || true
cp -f $MR_BUILD_SOURCE/libavutil/internal.h $MR_BUILD_PREFIX/include/libavutil/
cp -f $MR_BUILD_SOURCE/libavutil/libm.h $MR_BUILD_PREFIX/include/libavutil/
cp -f $MR_BUILD_SOURCE/libavutil/attributes_internal.h $MR_BUILD_PREFIX/include/libavutil/ &> /dev/null || true
cp -f $MR_BUILD_SOURCE/libavcodec/mathops.h $MR_BUILD_PREFIX/include/libavcodec/

mkdir -p $MR_BUILD_PREFIX/include/libavcodec/x86/
cp -f $MR_BUILD_SOURCE/libavcodec/x86/mathops.h $MR_BUILD_PREFIX/include/libavcodec/x86/
mkdir -p $MR_BUILD_PREFIX/include/libavutil/x86/
cp -f $MR_BUILD_SOURCE/libavutil/x86/asm.h $MR_BUILD_PREFIX/include/libavutil/x86/
#copy private header for hls.c
cp -f $MR_BUILD_SOURCE/libavformat/demux.h $MR_BUILD_PREFIX/include/libavformat/ &> /dev/null || true
cp -f $MR_BUILD_SOURCE/libavformat/http.h $MR_BUILD_PREFIX/include/libavformat/ &> /dev/null || true
cp -f $MR_BUILD_SOURCE/libavformat/hls_sample_encryption.h $MR_BUILD_PREFIX/include/libavformat/ &> /dev/null || true