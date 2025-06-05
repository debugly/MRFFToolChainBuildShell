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

FFMPEG_CFG_FLAGS=
FFMPEG_EXTRA_CFLAGS=
export COMMON_FF_CFG_FLAGS=
# use ijk ffmpeg config options
source $MR_SHELL_CONFIGS_DIR/ijk-ffmpeg-config/module-lite.sh
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS $COMMON_FF_CFG_FLAGS"

# Advanced options (experts only):
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-cross-compile"
# --disable-symver may indicate a bug
# FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-symver"

# Developer options (useful when working on FFmpeg itself):
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-stripping"

##
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --arch=$MR_FF_ARCH"
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --target-os=$MR_TAGET_OS"
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-static"
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-shared"
FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --pkg-config-flags=--static"

FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-pic"

case "$MR_DEBUG" in
    debug)
        FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-optimizations"
        FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-debug"
        FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-small"
    ;;
    *)
        FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-optimizations"
        FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-debug"
        FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-small"
    ;;
esac

# if [[ "$MR_ARCH" == "armv7a" || "$MR_ARCH" == "arm64" ]]; then
#     # enable asm
#     FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-neon"
#     FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-asm --enable-inline-asm"
# else
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-neon"
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-asm --disable-inline-asm"

    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-mmx"
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --assert-level=2"
# fi

FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --prefix=$MR_BUILD_PREFIX"

FFMPEG_CFLAGS="$MR_DEFAULT_CFLAGS"
FFMPEG_LDFLAGS="$FFMPEG_CFLAGS"

pkg-config --libs openssl --silence-errors >/dev/null && enable_openssl=1

if [[ $enable_openssl ]];then
    echo "[✅] --enable-openssl : $(pkg-config --modversion openssl)"
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-openssl"
else
    echo "[❌] --disable-openssl"
fi

#--------------------
echo "--------------------"
echo "[*] configure"
echo "----------------------"

if [ ! -d $MR_BUILD_SOURCE ]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find FFmpeg directory for $FF_BUILD_NAME"
    echo "!! Run 'sh init-ios.sh' first"
    echo ""
    exit 1
fi

cd $MR_BUILD_SOURCE
if [ -f "./config.h" ]; then
    echo 'reuse configure'
else
    echo
    echo "CC: $MR_TRIPLE_CC"
    echo "CFLAGS: $FFMPEG_CFLAGS"
    echo "LDFLAG:$FFMPEG_LDFLAGS"
    echo "FF_CFG_FLAGS: $FFMPEG_CFG_FLAGS"
    echo

    ./configure \
        $FFMPEG_CFG_FLAGS \
        --cc=${MR_TRIPLE_CC} \
        --as=${MR_TRIPLE_CC} \
        --ld=${MR_TRIPLE_CC} \
        --ar=${MR_AR} \
        --nm=${MR_NM} \
        --strip=${MR_STRIP} \
        --ranlib=${MR_RANLIB} \
        --extra-cflags="$FFMPEG_CFLAGS" \
        --extra-cxxflags="$FFMPEG_CFLAGS" \
        --extra-ldflags="$FFMPEG_LDFLAGS"
fi

#--------------------
echo "--------------------"
echo "[*] compile ffmpeg"
echo "--------------------"

make -j$MR_HOST_NPROC >/dev/null
cp config.* $MR_BUILD_PREFIX
make install >/dev/null
mkdir -p $MR_BUILD_PREFIX/include/libffmpeg
cp -f config.h $MR_BUILD_PREFIX/include/libffmpeg/config.h