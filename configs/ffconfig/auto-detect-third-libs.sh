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

# echo "----------------------"

# pkg-config --libs x264 --silence-errors >/dev/null && enable_x264=1

# if [[ $enable_x264 ]];then
#     echo "[✅] --enable-libx264 : $(pkg-config --modversion x264)"
#     THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-gpl --enable-libx264"
# else
#     echo "[❌] --disable-libx264"
# fi

# echo "----------------------"

# pkg-config --libs fdk-aac --silence-errors >/dev/null && enable_aac=1

# if [[ $enable_aac ]];then
#     echo "[✅] --enable-libfdk-aac : $(pkg-config --modversion fdk-aac)"
#     THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-nonfree --enable-libfdk-aac"
# else
#     echo "[❌] --disable-libfdk-aac"
# fi

# echo "----------------------"

# pkg-config --libs mp3lame --silence-errors >/dev/null && enable_lame=1

# if [[ $enable_lame ]];then
#     echo "[✅] --enable-libmp3lame : $(pkg-config --modversion mp3lame)"
#     THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-gpl --enable-libmp3lame"
# else
#     echo "[❌] --disable-libmp3lame"
# fi


# Function to compare two version numbers
# Returns:
#   1 if v1 == v2 or if v1 > v2
#   0 if v1 < v2
gt_or_equal() {
    local v1=$1
    local v2=$2
    local IFS=.
    # 将版本字符串按 "." 分割成数组
    # 例如 "7..1" 会变成 (7 "" 1)
    local v1_parts=($v1) v2_parts=($v2)
    local i

    # 确定两个版本号数组中的最大长度
    local len_v1=${#v1_parts[@]}
    local len_v2=${#v2_parts[@]}
    local max_len=$((len_v1 > len_v2 ? len_v1 : len_v2))

    for ((i=0; i<$max_len; i++)); do
        # 获取版本号的对应部分，如果部分缺失或为空字符串，则默认为 "0"
        local p1_val=${v1_parts[i]:-0}
        local p2_val=${v2_parts[i]:-0}

        # 进一步确保 p1_val 和 p2_val 是纯数字；如果不是，则视为 0
        # 这能处理像 "7.a.1" 这样包含非数字部分的情况
        if ! [[ "$p1_val" =~ ^[0-9]+$ ]]; then
            p1_val=0
        fi
        if ! [[ "$p2_val" =~ ^[0-9]+$ ]]; then
            p2_val=0
        fi

        # 进行数字比较
        # 使用 10# 前缀确保按十进制处理 (例如 "08" 被视为 8 而不是八进制)
        if ((10#$p1_val > 10#$p2_val)); then
            echo 1 # v1 > v2
            return 0
        fi
        if ((10#$p1_val < 10#$p2_val)); then
            echo # v1 < v2
            return 0
        fi
    done

    echo 1 # v1 == v2 (所有部分都相等)
    return 0
}

echo "----------------------"
# use pkg-config fix ff4.0--ijk0.8.8--20210426--001 use openssl 1_1_1m occur can't find openssl error.

pkg-config --libs openssl --silence-errors >/dev/null && enable_openssl=1

if [[ $enable_openssl ]];then
    echo "[✅] --enable-openssl : $(pkg-config --modversion openssl)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-nonfree --enable-openssl"
else
    echo "[❌] --disable-openssl"
fi

echo "----------------------"

pkg-config --libs opus --silence-errors >/dev/null && enable_opus=1

if [[ $enable_opus ]];then
    echo "[✅] --enable-libopus : $(pkg-config --modversion opus)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libopus --enable-decoder=opus"
else
    echo "[❌] --disable-libopus --disable-decoder=opus"
fi

echo "----------------------"

# FFmpeg 4.2 支持AV1、AVS2等格式
# dav1d由VideoLAN，VLC和FFmpeg联合开发，项目由AOM联盟赞助，和libaom相比，dav1d性能普遍提升100%，最高提升400%
#从FFmpeg7.1.1开始支持硬解av1，苹果需要M3芯片
result=$(gt_or_equal "$GIT_REPO_VERSION" "7.1.1")
if [[ $result ]]; then
    echo "[✅] --enable hw av1 decoder"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-decoder=av1"
else
    echo "[❌] --disable hw av1 decoder"
fi

echo "----------------------"

pkg-config --libs dav1d --silence-errors >/dev/null && enable_dav1d=1

if [[ $enable_dav1d ]];then
    echo "[✅] --enable-libdav1d : $(pkg-config --modversion dav1d)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libdav1d --enable-decoder=libdav1d"
else
    echo "[❌] --disable-libdav1d --disable-decoder=libdav1d"
fi

echo "----------------------"

pkg-config --libs libsmb2 --silence-errors >/dev/null && enable_smb2=1

if [[ $enable_smb2 ]];then
    echo "[✅] --enable-libsmb2 : $(pkg-config --modversion libsmb2)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libsmb2 --enable-protocol=libsmb2"
else
    echo "[❌] --disable-libsmb2 --disable-protocol=libsmb2"
fi

echo "----------------------"

pkg-config --libs libbluray --silence-errors >/dev/null && enable_bluray=1

if [[ $enable_bluray ]];then
    echo "[✅] --enable-libbluray : $(pkg-config --modversion libbluray)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libbluray --enable-protocol=bluray"
else
    echo "[❌] --disable-libbluray --disable-protocol=bluray"
fi
echo "----------------------"

#不确定7代之前的版本是否支持dvdvideo
result=$(gt_or_equal "$GIT_REPO_VERSION" "7.1.1")
if [[ $result ]]; then
    pkg-config --libs dvdread --silence-errors >/dev/null && enable_dvdread=1
    pkg-config --libs dvdnav --silence-errors >/dev/null && enable_dvdnav=1
    if [[ $enable_dvdread && $enable_dvdnav ]];then
        echo "[✅] --enable-demuxer=dvdvideo --enable-gpl --enable-libdvdread : $(pkg-config --modversion dvdread)"
        #libdvdread is gpl and --enable-gpl is not specified.
        THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libdvdread --enable-libdvdnav --enable-demuxer=dvdvideo --enable-gpl"
    else
        echo "[❌] --disable-dvdvideo"
    fi
else
    pkg-config --libs dvdread --silence-errors >/dev/null && enable_dvdread=1
    if [[ $enable_dvdread ]];then
        echo "[✅] --enable-libdvdread : $(pkg-config --modversion dvdread)"
        THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libdvdread --enable-protocol=dvd"
    else
        echo "[❌] --disable-dvd protocol"
    fi
fi

echo "----------------------"

pkg-config --libs uavs3d --silence-errors >/dev/null && enable_uavs3d=1

if [[ $enable_uavs3d ]];then
    echo "[✅] --enable-libuavs3d : $(pkg-config --modversion uavs3d)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libuavs3d --enable-decoder=libuavs3d"
else
    echo "[❌] --disable-libuavs3d --disable-decoder=libuavs3d"
fi

echo "----------------------"

pkg-config --libs libxml-2.0 --silence-errors >/dev/null && enable_xml2=1

if [[ $enable_xml2 ]];then
    echo "[✅] --enable-libxml2 : $(pkg-config --modversion libxml-2.0)"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-demuxer=dash --enable-libxml2"
else
    echo "[❌] --disable-demuxer=dash --disable-libxml2"
fi

echo "----------------------"

# export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR:/opt/homebrew/Cellar/shaderc/2024.0/lib/pkgconfig:/opt/homebrew/Cellar/little-cms2/2.16/lib/pkgconfig
# pkg-config --libs libplacebo --silence-errors >/dev/null && enable_placebo=1

# if [[ $enable_placebo ]];then
#     echo "[✅] --enable-libplacebo"
#     THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-libplacebo"
# else
#     echo "[❌] --disable-libplacebo"
# fi
# echo "----------------------"

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

# x86_64, arm64
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-pic"

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

##
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --arch=$MR_FF_ARCH"
THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --target-os=$MR_TAGET_OS"

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]]; then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --sysroot=$MR_SYS_ROOT"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-cross-compile"
fi

# for apple paltform

case "$MR_PLAT" in
    ios|macos|tvos)
    # enable asm
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-neon"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-asm --enable-inline-asm"
    # enable videotoolbox hwaccel
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-videotoolbox"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-hwaccel=*_videotoolbox"
    # enable iconv
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-iconv"
    ;;
    android)
    # enable mediacodec hwaccel
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-jni"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-mediacodec"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-decoder=h264_mediacodec --enable-hwaccel=h264_mediacodec"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-decoder=h265_mediacodec --enable-hwaccel=h265_mediacodec"
    # disable iconv
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-iconv"
    THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-bzlib"
    if [[ "$MR_ARCH" == "armv7a" || "$MR_ARCH" == "arm64" ]]; then
        # enable asm
        THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-neon"
        THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --enable-asm --enable-inline-asm"
    else
        THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-neon"
        THIRD_CFG_FLAGS="$THIRD_CFG_FLAGS --disable-asm --disable-inline-asm"
    fi
    ;;
esac