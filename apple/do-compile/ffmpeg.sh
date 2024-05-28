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

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
source $THIS_DIR/../../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_TAGET_OS"
env_assert "XC_ARCH"
env_assert "XC_PRODUCT_ROOT"
env_assert "XC_BUILD_NAME"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XCRUN_CC"
env_assert "THREAD_COUNT"
echo "XC_OPTS:$XC_OPTS"
echo "===check env end==="

# ffmpeg build params
source $THIS_DIR/../../ffconfig/module.sh
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
# https://gitlab.gnome.org/GNOME/gimp/-/issues/8649
# from clang 15 int <-> pointer conversions now defaults as an error
C_FLAGS="$C_FLAGS -Wno-int-conversion -fno-stack-check -arch $XC_ARCH"
C_FLAGS="$C_FLAGS $XC_DEPLOYMENT_TARGET $XC_OTHER_CFLAGS"

if [[ "$XC_OPTS" == "debug" ]]; then
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


CFG_FLAGS="$CFG_FLAGS --pkg-config-flags=--static"

LDFLAGS="$C_FLAGS"
FFMPEG_DEP_LIBS=

echo "----------------------"
echo "[*] check OpenSSL"

# https://ffmpeg.org/doxygen/4.1/md_LICENSE.html
# https://www.openssl.org/source/license.html

MY_PKG_CONFIG_LIBDIR=''
# with openssl
# use pkg-config fix ff4.0--ijk0.8.8--20210426--001 use openssl 1_1_1m occur can't find openssl error.
if [[ -f "${XC_PRODUCT_ROOT}/openssl-$XC_ARCH/lib/pkgconfig/openssl.pc" ]]; then
    CFG_FLAGS="$CFG_FLAGS --enable-nonfree --enable-openssl"
    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/openssl-$XC_ARCH/lib/pkgconfig"

    echo "[*] --enable-openssl"
elif [[ -f "${XC_PRODUCT_ROOT}/universal/openssl/lib/pkgconfig/openssl.pc" ]]; then
    CFG_FLAGS="$CFG_FLAGS --enable-nonfree --enable-openssl"
    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/universal/openssl/lib/pkgconfig"

    echo "[*] --enable-openssl"   
else
    echo "[*] --disable-openssl"
fi

echo "----------------------"
echo "[*] check x264"

# with x264
if [[ -f "${XC_PRODUCT_ROOT}/x264-$XC_ARCH/lib/pkgconfig/x264.pc" ]]; then
    # libx264 is gpl and --enable-gpl is not specified.
    CFG_FLAGS="$CFG_FLAGS --enable-gpl --enable-libx264"

    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/x264-$XC_ARCH/lib/pkgconfig"

    echo "[*] --enable-libx264"
else
    echo "[*] --disable-libx264"
fi

echo "----------------------"
echo "[*] check fdk-aac"

# with fdk-aac
if [[ -f "${XC_PRODUCT_ROOT}/fdk-aac-$XC_ARCH/lib/pkgconfig/fdk-aac.pc" ]]; then

    CFG_FLAGS="$CFG_FLAGS --enable-nonfree --enable-libfdk-aac"

    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/fdk-aac-$XC_ARCH/lib/pkgconfig"

    echo "[*] --enable-libfdk-aac"
else
    echo "[*] --disable-libfdk-aac"
fi

echo "----------------------"
echo "[*] check mp3lame"

# with lame
if [[ -f "${XC_PRODUCT_ROOT}/lame-$XC_ARCH/lib/libmp3lame.a" ]]; then
    # libmp3lame is gpl and --enable-gpl is not specified.
    CFG_FLAGS="$CFG_FLAGS --enable-gpl --enable-libmp3lame"

    FDKAAC_C_FLAGS="-I${XC_PRODUCT_ROOT}/lame-$XC_ARCH/include"
    FDKAAC_LD_FLAGS="-L${XC_PRODUCT_ROOT}/lame-$XC_ARCH/lib -lmp3lame"

    C_FLAGS="$C_FLAGS $FDKAAC_C_FLAGS"
    FFMPEG_DEP_LIBS="$FFMPEG_DEP_LIBS $FDKAAC_LD_FLAGS"
    echo "[*] --enable-libmp3lame"
else
    echo "[*] --disable-libmp3lame"
fi

echo "----------------------"
echo "[*] check opus"

# with opus
if [[ -f "${XC_PRODUCT_ROOT}/opus-$XC_ARCH/lib/pkgconfig/opus.pc" ]]; then

    CFG_FLAGS="$CFG_FLAGS --enable-libopus --enable-decoder=opus"

    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/opus-$XC_ARCH/lib/pkgconfig"

    echo "[*] --enable-libopus --enable-decoder=opus"
elif [[ -f "${XC_PRODUCT_ROOT}/universal/opus/lib/pkgconfig/opus.pc" ]]; then

    CFG_FLAGS="$CFG_FLAGS --enable-libopus --enable-decoder=opus"

    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/universal/opus/lib/pkgconfig"

    echo "[*] --enable-libopus --enable-decoder=opus"
else
    echo "[*] --disable-libopus"
fi

echo "----------------------"
echo "[*] check dav1d"

# FFmpeg 4.2 支持AV1、AVS2等格式
# dav1d由VideoLAN，VLC和FFmpeg联合开发，项目由AOM联盟赞助，和libaom相比，dav1d性能普遍提升100%，最高提升400%
if [[ -f "${XC_PRODUCT_ROOT}/dav1d-$XC_ARCH/lib/pkgconfig/dav1d.pc" ]]; then

    CFG_FLAGS="$CFG_FLAGS --enable-libdav1d --enable-decoder=libdav1d"

    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/dav1d-$XC_ARCH/lib/pkgconfig"

    echo "[*] --enable-libdav1d --enable-decoder=libdav1d"
elif [[ -f "${XC_PRODUCT_ROOT}/universal/dav1d/lib/pkgconfig/dav1d.pc" ]]; then

    CFG_FLAGS="$CFG_FLAGS --enable-libdav1d --enable-decoder=libdav1d"

    if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
        MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
    fi
    MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/universal/dav1d/lib/pkgconfig"

    echo "[*] --enable-libdav1d --enable-decoder=libdav1d"
else
    echo "[*] --disable-libdav1d --disable-decoder=libdav1d"
fi

#just wait videotoolbox support decode av1
# CFG_FLAGS="$CFG_FLAGS --enable-decoder=av1"

# echo "----------------------"
# echo "[*] check bluray"

# # with bluray
# if [[ -f "${XC_PRODUCT_ROOT}/bluray-$XC_ARCH/lib/pkgconfig/libbluray.pc" ]]; then

# # --enable-libxml2
#     CFG_FLAGS="$CFG_FLAGS --enable-libbluray --enable-protocol=bluray"

#     if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
#         MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
#     fi
#     MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/bluray-$XC_ARCH/lib/pkgconfig"

#     echo "[*] --enable-libbluray --enable-protocol=bluray"
# elif [[ -f "${XC_PRODUCT_ROOT}/universal/bluray/lib/pkgconfig/libbluray.pc" ]]; then
# # --enable-libxml2
#     CFG_FLAGS="$CFG_FLAGS --enable-libbluray --enable-protocol=bluray"

#     if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
#         MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
#     fi
#     MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/universal/bluray/lib/pkgconfig"

#     echo "[*] --enable-libbluray --enable-protocol=bluray"
# else
#     echo "[*] --disable-libbluray --disable-protocol=bluray"
# fi

# echo "----------------------"
# echo "[*] check dvdread"

# if [[ -f "${XC_PRODUCT_ROOT}/dvdread-$XC_ARCH/lib/pkgconfig/dvdread.pc" || -f "${XC_PRODUCT_ROOT}/universal/dvdread/lib/pkgconfig/dvdread.pc" ]]; then

#     CFG_FLAGS="$CFG_FLAGS --enable-libdvdread"

#     if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
#         MY_PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR:"
#     fi

#     if [[ -f "${XC_PRODUCT_ROOT}/dvdread-$XC_ARCH/lib/pkgconfig/dvdread.pc" ]]; then
#         MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/dvdread-$XC_ARCH/lib/pkgconfig"
#     else
#         MY_PKG_CONFIG_LIBDIR="${MY_PKG_CONFIG_LIBDIR}${XC_PRODUCT_ROOT}/universal/dvdread/lib/pkgconfig"
#     fi

#     echo "[*] --enable-libdvdread"
# else
#     echo "[*] --disable-libdvdread"
# fi


echo "----------------------"
echo "[*] PKG_CONFIG_LIBDIR"

if [[ -n "$MY_PKG_CONFIG_LIBDIR" ]]; then
    export PKG_CONFIG_LIBDIR="$MY_PKG_CONFIG_LIBDIR"
fi

echo "export PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR}"

# pkg-config --variable pc_path pkg-config
# pkg-config --libs dav1d
# pkg-config --cflags --libs libbluray

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

make -j$THREAD_COUNT >/dev/null

echo "----------------------"
echo "[*] install"

cp config.* $XC_BUILD_PREFIX
make install >/dev/null
mkdir -p $XC_BUILD_PREFIX/include/libffmpeg
cp -f config.h $XC_BUILD_PREFIX/include/libffmpeg/config.h
# copy private header.
#cp -f $XC_BUILD_SOURCE/libavformat/avc.h $XC_BUILD_PREFIX/include/libavformat/avc.h
