#! /usr/bin/env bash
#
# Copyright (C) 2013-2014 Zhang Rui <bbcallen@gmail.com>
#
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

#----------
# modify for your build tool

FF_ALL_ARCHS_DEFAULT_SDK="arm64 x86_64"

FF_ALL_ARCHS=$FF_ALL_ARCHS_DEFAULT_SDK

#----------
UNI_BUILD_ROOT=`pwd`
UNI_TMP="$UNI_BUILD_ROOT/tmp"
UNI_TMP_LLVM_VER_FILE="$UNI_TMP/llvm.ver.txt"
FF_TARGET=$1
FF_TARGET_EXTRA=$2
set -e

#----------
echo_archs() {
    echo "===================="
    echo "xcode version:"
    echo $(xcodebuild -version)
    echo "===================="
    echo "FF_ALL_ARCHS = $FF_ALL_ARCHS"
}

FF_LIBS="libavcodec libavfilter libavformat libavutil libswscale libswresample libavdevice"
do_lipo_ffmpeg () {
    LIB_FILE=$1
    LIPO_FLAGS=
    for ARCH in $FF_ALL_ARCHS
    do
        ARCH_LIB_FILE="$UNI_BUILD_ROOT/build/ffmpeg-$ARCH/output/lib/$LIB_FILE"
        if [ -f "$ARCH_LIB_FILE" ]; then
            LIPO_FLAGS="$LIPO_FLAGS $ARCH_LIB_FILE"
        else
            echo "skip $LIB_FILE of $ARCH";
        fi
    done

    xcrun lipo -create $LIPO_FLAGS -output $UNI_BUILD_ROOT/build/universal/ffmpeg/lib/$LIB_FILE
    xcrun lipo -info $UNI_BUILD_ROOT/build/universal/ffmpeg/lib/$LIB_FILE
}

do_lipo_all () {
    rm -rf $UNI_BUILD_ROOT/build/universal/ffmpeg
    mkdir -p $UNI_BUILD_ROOT/build/universal/ffmpeg/lib
    echo "lipo archs: $FF_ALL_ARCHS"
    for FF_LIB in $FF_LIBS
    do
        do_lipo_ffmpeg "$FF_LIB.a";
    done

    for ARCH in $FF_ALL_ARCHS
    do
        ARCH_INC_DIR="$UNI_BUILD_ROOT/build/ffmpeg-$ARCH/output/include"
        ARCH_OUT_DIR="$UNI_BUILD_ROOT/build/universal/ffmpeg/include"
        if [[ -d "$ARCH_INC_DIR" && ! -d "$ARCH_OUT_DIR" ]]; then
            echo "copy include dir to $ARCH_OUT_DIR"
            cp -R "$ARCH_INC_DIR" "$ARCH_OUT_DIR"
            break
        fi
    done
}

#----------
if [ "$FF_TARGET" = "lipo" ]; then
    echo_archs
    do_lipo_all
elif [ "$FF_TARGET" = "all" ]; then
    echo_archs
    for ARCH in $FF_ALL_ARCHS
    do
        sh tools/do-compile-ffmpeg.sh $ARCH $FF_TARGET_EXTRA
    done

    do_lipo_all
elif [ "$FF_TARGET" = "check" ]; then
    echo_archs
elif [ "$FF_TARGET" = "clean" ]; then
    if [ "x$2" != "x" ];then
        MY_FF_TARGET="$2"
    else 
        MY_FF_TARGET="$FF_ALL_ARCHS"
    fi
    for ARCH in $MY_FF_TARGET
    do
        cd ffmpeg-$ARCH && git clean -xdf && cd - >/dev/null
        rm -rf build/ffmpeg-$ARCH
    done
    rm -rf build/universal/ffmpeg
else

    for ARCH in $FF_ALL_ARCHS
    do
        if [ "$FF_TARGET" = "$ARCH" ]; then
            MY_FF_TARGET="$ARCH"
        fi
    done

    if [ "x$MY_FF_TARGET" != 'x' ]; then
        sh tools/do-compile-ffmpeg.sh $MY_FF_TARGET $FF_TARGET_EXTRA
    else
        echo "Usage:"
        echo "    $0 all"
        echo "    $0 x86_64"
        echo "    $0 arm64"
        echo "    $0 lipo"
        echo "    $0 clean"
        echo "    $0 clean x86_64"
        echo "    $0 clean arm64"
        echo "    $0 check"
    fi
fi
