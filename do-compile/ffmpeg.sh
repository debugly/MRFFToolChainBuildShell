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
    tail -n20 ${XC_BUILD_SOURCE}/ffbuild/config.log
}

trap 'error_handler' ERR

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"
source ../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_ARCH"
env_assert "XC_TAGET_OS"
env_assert "XC_BUILD_NAME"
env_assert "XCRUN_CC"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XCRUN_SDK_PATH"
env_assert "XC_THREAD"
echo "PKG_CONFIG_LIBDIR:$PKG_CONFIG_LIBDIR"
echo "XC_DEBUG:$XC_DEBUG"
echo "===check env end==="

# ffmpeg build params
source $THIS_DIR/../configs/ffconfig/module.sh
CFG_FLAGS="$COMMON_FF_CFG_FLAGS"

CFG_FLAGS="--prefix=$XC_BUILD_PREFIX $CFG_FLAGS"

# Developer options (useful when working on FFmpeg itself):
# CFG_FLAGS="$CFG_FLAGS --disable-stripping"

##
CFG_FLAGS="$CFG_FLAGS --arch=$XC_ARCH"
CFG_FLAGS="$CFG_FLAGS --target-os=$XC_TAGET_OS"
CFG_FLAGS="$CFG_FLAGS --enable-static"
CFG_FLAGS="$CFG_FLAGS --disable-shared"

# x86_64, arm64
CFG_FLAGS="$CFG_FLAGS --enable-pic"
CFG_FLAGS="$CFG_FLAGS --enable-neon"
CFG_FLAGS="$CFG_FLAGS --enable-asm"

C_FLAGS=
C_FLAGS="$C_FLAGS -arch $XC_ARCH"
C_FLAGS="$C_FLAGS $XC_DEPLOYMENT_TARGET $XC_OTHER_CFLAGS"

if [[ "$XC_DEBUG" == "debug" ]]; then
    CFG_FLAGS="$CFG_FLAGS --disable-optimizations"
    CFG_FLAGS="$CFG_FLAGS --enable-debug"
    CFG_FLAGS="$CFG_FLAGS --disable-small"
    #C_FLAGS="$C_FLAGS -D DEBUG_BLURAY=1"
else
    CFG_FLAGS="$CFG_FLAGS --enable-optimizations"
    CFG_FLAGS="$CFG_FLAGS --disable-debug"
    CFG_FLAGS="$CFG_FLAGS --enable-small"
fi

# for cross compile
if [[ $(uname -m) != "$XC_ARCH" || "$XC_FORCE_CROSS" ]]; then
    echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    C_FLAGS="$C_FLAGS --sysroot $XCRUN_SDK_PATH"
    CFG_FLAGS="$CFG_FLAGS --enable-cross-compile"
fi


# --enable-debug
CFG_FLAGS="$CFG_FLAGS --pkg-config-flags=--static"

LDFLAGS="$C_FLAGS"
FFMPEG_DEP_LIBS=

# https://ffmpeg.org/doxygen/4.1/md_LICENSE.html
# https://www.openssl.org/source/license.html

# pkg-config --variable pc_path pkg-config
# pkg-config --libs dav1d
# pkg-config --cflags --libs libbluray

echo "----------------------"

pkg-config --libs x264 --silence-errors >/dev/null && enable_x264=1

if [[ $enable_x264 ]];then
    echo "[✅] --enable-libx264"
    CFG_FLAGS="$CFG_FLAGS --enable-gpl --enable-libx264"
else
    echo "[❌] --disable-libx264"
fi

echo "----------------------"

pkg-config --libs fdk-aac --silence-errors >/dev/null && enable_aac=1

if [[ $enable_aac ]];then
    echo "[✅] --enable-libfdk-aac"
    CFG_FLAGS="$CFG_FLAGS --enable-nonfree --enable-libfdk-aac"
else
    echo "[❌] --disable-libfdk-aac"
fi

echo "----------------------"

pkg-config --libs mp3lame --silence-errors >/dev/null && enable_lame=1

if [[ $enable_lame ]];then
    echo "[✅] --enable-libmp3lame"
    CFG_FLAGS="$CFG_FLAGS --enable-gpl --enable-libmp3lame"
else
    echo "[❌] --disable-libmp3lame"
fi

echo "----------------------"
# use pkg-config fix ff4.0--ijk0.8.8--20210426--001 use openssl 1_1_1m occur can't find openssl error.

pkg-config --libs openssl --silence-errors >/dev/null && enable_openssl=1

if [[ $enable_openssl ]];then
    echo "[✅] --enable-openssl"
    CFG_FLAGS="$CFG_FLAGS --enable-nonfree --enable-openssl"
else
    echo "[❌] --disable-openssl"
fi

echo "----------------------"

pkg-config --libs opus --silence-errors >/dev/null && enable_opus=1

if [[ $enable_opus ]];then
    echo "[✅] --enable-libopus"
    CFG_FLAGS="$CFG_FLAGS --enable-libopus --enable-decoder=opus"
else
    echo "[❌] --disable-libopus"
fi

echo "----------------------"
# FFmpeg 4.2 支持AV1、AVS2等格式
# dav1d由VideoLAN，VLC和FFmpeg联合开发，项目由AOM联盟赞助，和libaom相比，dav1d性能普遍提升100%，最高提升400%
#just wait videotoolbox support decode av1
# CFG_FLAGS="$CFG_FLAGS --enable-decoder=av1"

pkg-config --libs dav1d --silence-errors >/dev/null && enable_dav1d=1

if [[ $enable_dav1d ]];then
    echo "[✅] --enable-libdav1d"
    CFG_FLAGS="$CFG_FLAGS --enable-libdav1d --enable-decoder=libdav1d"
else
    echo "[❌] --disable-libdav1d"
fi

echo "----------------------"

pkg-config --libs libsmb2 --silence-errors >/dev/null && enable_smb2=1

if [[ $enable_smb2 ]];then
    echo "[✅] --enable-libsmb2"
    CFG_FLAGS="$CFG_FLAGS --enable-libsmb2 --enable-protocol=libsmb2"
else
    echo "[❌] --disable-libsmb2"
fi

echo "----------------------"

pkg-config --libs libbluray --silence-errors >/dev/null && enable_bluray=1

if [[ $enable_bluray ]];then
    echo "[✅] --enable-libbluray"
    CFG_FLAGS="$CFG_FLAGS --enable-libbluray --enable-protocol=bluray"
else
    echo "[❌] --disable-libbluray"
fi
echo "----------------------"

pkg-config --libs dvdread --silence-errors >/dev/null && enable_dvdread=1

if [[ $enable_dvdread ]];then
    echo "[✅] --enable-libdvdread"
    CFG_FLAGS="$CFG_FLAGS --enable-libdvdread --enable-protocol=dvd"
else
    echo "[❌] --disable-libdvdread"
fi

echo "----------------------"

pkg-config --libs uavs3d --silence-errors >/dev/null && enable_uavs3d=1

if [[ $enable_uavs3d ]];then
    echo "[✅] --enable-libuavs3d"
    CFG_FLAGS="$CFG_FLAGS --enable-libuavs3d --enable-decoder=libuavs3d"
else
    echo "[❌] --disable-libuavs3d"
fi

echo "----------------------"

# pkg-config --libs avs3ad --silence-errors >/dev/null && enable_avs3ad=1

# if [[ $enable_avs3ad ]];then
#     echo "[✅] --enable-decoder=av3a"
#     CFG_FLAGS="$CFG_FLAGS --enable-parser=av3a"
# else
#     echo "[❌] --disable-decoder=av3a"
# fi

echo "[✅] --enable-parser=av3a"
CFG_FLAGS="$CFG_FLAGS --enable-parser=av3a --enable-demuxer=av3a"

echo "----------------------"
echo "[*] configure"

if [[ ! -d $XC_BUILD_SOURCE ]]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find $XC_BUILD_SOURCE directory for $XC_BUILD_NAME"
    echo "!! Run 'init-*.sh' first"
    echo ""
    exit 1
fi

cd $XC_BUILD_SOURCE
if [[ -f "./config.h" ]]; then
    echo 'reuse configure'
else
    echo
    echo "CC: $XCRUN_CC"
    echo
    echo "CFLAGS: $C_FLAGS"
    echo
    echo "FF_CFG_FLAGS: $CFG_FLAGS"
    echo
    echo "LDFLAG:$LDFLAGS $FFMPEG_DEP_LIBS"
    echo
    ./configure \
        $CFG_FLAGS \
        --cc="$XCRUN_CC" \
        --extra-cflags="$C_FLAGS" \
        --extra-cxxflags="$C_FLAGS" \
        --extra-ldflags="$LDFLAGS $FFMPEG_DEP_LIBS"
fi

#----------------------
echo "----------------------"
echo "[*] compile"

make -j$XC_THREAD >/dev/null

echo "----------------------"
echo "[*] install"

cp config.* $XC_BUILD_PREFIX
make install >/dev/null
mkdir -p $XC_BUILD_PREFIX/include/libffmpeg
cp -f config.h $XC_BUILD_PREFIX/include/libffmpeg/
cp -f config_components.h $XC_BUILD_PREFIX/include/libffmpeg/
# copy private header for ffmpeg-kit.
cp -f $XC_BUILD_SOURCE/libavutil/getenv_utf8.h $XC_BUILD_PREFIX/include/libavutil/
cp -f $XC_BUILD_SOURCE/libavutil/internal.h $XC_BUILD_PREFIX/include/libavutil/
cp -f $XC_BUILD_SOURCE/libavutil/libm.h $XC_BUILD_PREFIX/include/libavutil/
cp -f $XC_BUILD_SOURCE/libavutil/attributes_internal.h $XC_BUILD_PREFIX/include/libavutil/
cp -f $XC_BUILD_SOURCE/libavcodec/mathops.h $XC_BUILD_PREFIX/include/libavcodec/

mkdir -p $XC_BUILD_PREFIX/include/libavcodec/x86/
cp -f $XC_BUILD_SOURCE/libavcodec/x86/mathops.h $XC_BUILD_PREFIX/include/libavcodec/x86/
mkdir -p $XC_BUILD_PREFIX/include/libavutil/x86/
cp -f $XC_BUILD_SOURCE/libavutil/x86/asm.h $XC_BUILD_PREFIX/include/libavutil/x86/
