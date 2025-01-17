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

# https://ffmpeg.org/doxygen/4.1/md_LICENSE.html
# https://www.openssl.org/source/license.html

# pkg-config --variable pc_path pkg-config
# pkg-config --libs dav1d
# pkg-config --cflags --libs libbluray

THIRD_CFG_FLAGS=

echo "----------------------"

pkg-config --libs x264 --silence-errors >/dev/null && enable_x264=1

if [[ $enable_x264 ]];then
    echo "[✅] --enable-libx264"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-gpl --enable-libx264"
else
    echo "[❌] --disable-libx264"
fi

echo "----------------------"

pkg-config --libs fdk-aac --silence-errors >/dev/null && enable_aac=1

if [[ $enable_aac ]];then
    echo "[✅] --enable-libfdk-aac"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-nonfree --enable-libfdk-aac"
else
    echo "[❌] --disable-libfdk-aac"
fi

echo "----------------------"

pkg-config --libs mp3lame --silence-errors >/dev/null && enable_lame=1

if [[ $enable_lame ]];then
    echo "[✅] --enable-libmp3lame"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-gpl --enable-libmp3lame"
else
    echo "[❌] --disable-libmp3lame"
fi

echo "----------------------"
# use pkg-config fix ff4.0--ijk0.8.8--20210426--001 use openssl 1_1_1m occur can't find openssl error.

pkg-config --libs openssl --silence-errors >/dev/null && enable_openssl=1

if [[ $enable_openssl ]];then
    echo "[✅] --enable-openssl"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-nonfree --enable-openssl"
else
    echo "[❌] --disable-openssl"
fi

echo "----------------------"

pkg-config --libs opus --silence-errors >/dev/null && enable_opus=1

if [[ $enable_opus ]];then
    echo "[✅] --enable-libopus"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libopus --enable-decoder=opus"
else
    echo "[❌] --disable-libopus"
fi

echo "----------------------"
# FFmpeg 4.2 支持AV1、AVS2等格式
# dav1d由VideoLAN，VLC和FFmpeg联合开发，项目由AOM联盟赞助，和libaom相比，dav1d性能普遍提升100%，最高提升400%
#just wait videotoolbox support decode av1
# THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-decoder=av1"

pkg-config --libs dav1d --silence-errors >/dev/null && enable_dav1d=1

if [[ $enable_dav1d ]];then
    echo "[✅] --enable-libdav1d"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libdav1d --enable-decoder=libdav1d"
else
    echo "[❌] --disable-libdav1d"
fi

echo "----------------------"

pkg-config --libs libsmb2 --silence-errors >/dev/null && enable_smb2=1

if [[ $enable_smb2 ]];then
    echo "[✅] --enable-libsmb2"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libsmb2 --enable-protocol=libsmb2"
else
    echo "[❌] --disable-libsmb2"
fi

echo "----------------------"

pkg-config --libs libbluray --silence-errors >/dev/null && enable_bluray=1

if [[ $enable_bluray ]];then
    echo "[✅] --enable-libbluray"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libbluray --enable-protocol=bluray"
else
    echo "[❌] --disable-libbluray"
fi
echo "----------------------"

pkg-config --libs dvdread --silence-errors >/dev/null && enable_dvdread=1

if [[ $enable_dvdread ]];then
    echo "[✅] --enable-libdvdread"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libdvdread --enable-protocol=dvd"
else
    echo "[❌] --disable-libdvdread"
fi

echo "----------------------"

pkg-config --libs uavs3d --silence-errors >/dev/null && enable_uavs3d=1

if [[ $enable_uavs3d ]];then
    echo "[✅] --enable-libuavs3d"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libuavs3d --enable-decoder=libuavs3d"
else
    echo "[❌] --disable-libuavs3d"
fi

echo "----------------------"

# pkg-config --libs avs3ad --silence-errors >/dev/null && enable_avs3ad=1

# if [[ $enable_avs3ad ]];then
#     echo "[✅] --enable-decoder=av3a"
#     THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-parser=av3a"
# else
#     echo "[❌] --disable-decoder=av3a"
# fi

echo "[✅] --enable-parser=av3a"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-parser=av3a --enable-demuxer=av3a"
echo "----------------------"

# --------------------------------------------------------------
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --pkg-config-flags=--static"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-static"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-shared"

THIRD_CFG_FLAGS="--prefix=$MR_BUILD_PREFIX $THIRD_CFG_FLAGS"

# Developer options (useful when working on FFmpeg itself):
# THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-stripping"

##
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --arch=$MR_FF_ARCH"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --target-os=$MR_TAGET_OS"

# x86_64, arm64
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-pic"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-neon"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-asm"

if [[ "$MR_DEBUG" == "debug" ]]; then
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-optimizations"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-debug"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-small"
    #C_FLAGS="$C_FLAGS -D DEBUG_BLURAY=1"
else
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-optimizations"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-debug"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-small"
fi

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]]; then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --sysroot=$MR_SYS_ROOT"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-cross-compile"
fi

# for apple paltform

case "$MR_PLAT" in
    ios|macos|tvos)
    # enable videotoolbox hwaccel
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-videotoolbox"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-hwaccel=*_videotoolbox"
    # enable iconv
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-iconv"
    ;;
esac