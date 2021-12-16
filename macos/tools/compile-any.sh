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

# 调用这个脚本时的目录
UNI_BUILD_ROOT=`pwd`
export XC_UNI_BUILD_DIR="${UNI_BUILD_ROOT}/build/universal"

# 当前脚本所在目录
TOOLS=$(dirname "$0")
source $TOOLS/../../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "ALL_ARCHS"
env_assert "LIPO_LIBS"
env_assert "LIB_NAME"
echo "ARGV:$*"
echo "===check env end==="

do_lipo_lib () {
    LIB_FILE=$1
    LIPO_FLAGS=
    for arch in $ALL_ARCHS
    do
        ARCH_LIB_FILE="$UNI_BUILD_ROOT/build/$LIB_NAME-$arch/output/lib/$LIB_FILE"
        if [ -f "$ARCH_LIB_FILE" ]; then
            LIPO_FLAGS="$LIPO_FLAGS $ARCH_LIB_FILE"
        else
            echo "skip $LIB_FILE of $arch";
        fi
    done

    xcrun lipo -create $LIPO_FLAGS -output $XC_UNI_BUILD_DIR/$LIB_NAME/lib/$LIB_FILE
    xcrun lipo -info $XC_UNI_BUILD_DIR/$LIB_NAME/lib/$LIB_FILE
}

do_lipo_all () {
    rm -rf $XC_UNI_BUILD_DIR/$LIB_NAME
    mkdir -p $XC_UNI_BUILD_DIR/$LIB_NAME/lib
    echo "lipo archs: $ALL_ARCHS"
    for lib in $LIPO_LIBS
    do
        do_lipo_lib "$lib.a";
    done

    for arch in $ALL_ARCHS
    do
        ARCH_INC_DIR="$UNI_BUILD_ROOT/build/$LIB_NAME-$arch/output/include"
        ARCH_OUT_DIR="$XC_UNI_BUILD_DIR/$LIB_NAME/include"
        if [[ -d "$ARCH_INC_DIR" && ! -d "$ARCH_OUT_DIR" ]]; then
            echo "copy include dir to $ARCH_OUT_DIR"
            cp -R "$ARCH_INC_DIR" "$ARCH_OUT_DIR"
            break
        fi
    done
}

function do_compile()
{
    # x86_64
    export XC_ARCH=$1
    # ffmpeg-x86_64
    export XC_BUILD_NAME="${LIB_NAME}-${XC_ARCH}"
    # mac/ffmpeg-x86_64
    export XC_BUILD_SOURCE="${UNI_BUILD_ROOT}/${XC_BUILD_NAME}"
    # mac/build/ffmpeg-x86_64/ouput
    export XC_BUILD_PREFIX="${UNI_BUILD_ROOT}/build/${XC_BUILD_NAME}/output"

    if [ ! -d $XC_BUILD_SOURCE ]; then
        echo ""
        echo "!! ERROR"
        echo "!! Can not find $XC_BUILD_SOURCE directory for $XC_BUILD_NAME"
        echo "!! Run 'init-*.sh' first"
        echo ""
        exit 1
    fi

    mkdir -p "$XC_BUILD_PREFIX"

    echo
    echo "will compile $XC_BUILD_SOURCE"
    local opt=$2
    sh $TOOLS/do-compile-$LIB_NAME.sh $opt
}

function resolove_dep() {
    echo "[*] check depends bins: ${LIB_DEPENDS_BIN}"
    for b in ${LIB_DEPENDS_BIN}
    do
        install_depends "$b"
    done
    echo "===================="
}

function main() {

    local cmd=$1
    local opt=$2
    
    echo "cmd is [$cmd]"

    if [ "$cmd" = "lipo" ]; then
        do_lipo_all
    elif [ "$cmd" = "all" ]; then
        resolove_dep
        for arch in $ALL_ARCHS
        do
            do_compile $arch "$opt"
        done

        do_lipo_all
    elif [ "$cmd" = "clean" ]; then
        if [ "x$opt" != "x" ];then
            MY_TARGET="$opt"
        else 
            MY_TARGET="$ALL_ARCHS"
        fi
        for arch in $MY_TARGET
        do
            cd $LIB_NAME-$arch && git clean -xdf && cd - >/dev/null
            rm -rf build/$LIB_NAME-$arch
        done
        rm -rf build/universal/$LIB_NAME
        echo 'done.'
        exit 1
    else

        for arch in $ALL_ARCHS
        do
            if [ "$cmd" = "$arch" ]; then
                MY_TARGET="$arch"
            fi
        done

        if [ "x$MY_TARGET" != 'x' ]; then
            resolove_dep
            do_compile $MY_TARGET "$opt"
        else
            echo "Usage:"
            echo "    $0 all"
            echo "    $0 x86_64"
            echo "    $0 arm64"
            echo "    $0 lipo"
            echo "    $0 clean"
            echo "    $0 clean x86_64"
            echo "    $0 clean arm64"
            exit 1
        fi
    fi
}

main $*