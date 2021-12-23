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
SHELL_ROOT=`pwd`

export XC_SRC_ROOT="${SHELL_ROOT}/../build/src/macos"
export XC_PRODUCT_ROOT="${SHELL_ROOT}/../build/product/macos"
export XC_UNI_PROD_DIR="${XC_PRODUCT_ROOT}/universal"

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
    local LIB_FILE=$1
    local MY_TARGET="$2"
    local LIPO_FLAGS=
    for arch in $MY_TARGET
    do
        local ARCH_LIB_FILE="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/lib/$LIB_FILE"
        if [ -f "$ARCH_LIB_FILE" ]; then
            LIPO_FLAGS="$LIPO_FLAGS $ARCH_LIB_FILE"
        else
            echo "can't find the $arch arch $LIB_FILE"
            exit 1
        fi
    done

    xcrun lipo -create $LIPO_FLAGS -output $XC_UNI_PROD_DIR/$LIB_NAME/lib/$LIB_FILE
    xcrun lipo -info $XC_UNI_PROD_DIR/$LIB_NAME/lib/$LIB_FILE
}

do_lipo_all () {
    local MY_TARGET="$1"
    rm -rf $XC_UNI_PROD_DIR/$LIB_NAME
    mkdir -p $XC_UNI_PROD_DIR/$LIB_NAME/lib
    echo "lipo archs: $MY_TARGET"
    for lib in $LIPO_LIBS
    do
        do_lipo_lib "$lib.a" "$MY_TARGET"
    done

    for arch in $MY_TARGET
    do
        local ARCH_INC_DIR="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/include"
        local ARCH_OUT_DIR="$XC_UNI_PROD_DIR/$LIB_NAME/include"
        if [[ -d "$ARCH_INC_DIR" && ! -d "$ARCH_OUT_DIR" ]]; then
            echo "copy include dir to $ARCH_OUT_DIR"
            cp -R "$ARCH_INC_DIR" "$ARCH_OUT_DIR"
            break
        fi
    done
}

function export_arch_env()
{
    # x86_64
    export XC_ARCH=$1
    # ffmpeg-x86_64
    export XC_BUILD_NAME="${LIB_NAME}-${XC_ARCH}"
    # macos/ffmpeg-x86_64
    export XC_BUILD_SOURCE="${XC_SRC_ROOT}/${XC_BUILD_NAME}"
    # macos/ffmpeg-x86_64
    export XC_BUILD_PREFIX="${XC_PRODUCT_ROOT}/${XC_BUILD_NAME}"
}

function do_compile()
{
    export_arch_env $1
    if [ ! -d $XC_BUILD_SOURCE ]; then
        echo ""
        echo "!! ERROR"
        echo "!! Can not find $XC_BUILD_SOURCE directory for $XC_BUILD_NAME"
        echo "!! Run init-any.sh ${LIB_NAME} first"
        echo ""
        exit 1
    fi

    mkdir -p "$XC_BUILD_PREFIX"
    echo "will compile $XC_BUILD_SOURCE"
    local opt=$2
    ./do-compile/$LIB_NAME.sh $opt
}

function resolve_dep()
{
    echo "[*] check depends bins: ${LIB_DEPENDS_BIN}"
    for b in ${LIB_DEPENDS_BIN}
    do
        install_depends "$b"
    done
    echo "===================="
}

function do_clean()
{
    export_arch_env $1
    cd $XC_BUILD_SOURCE && git clean -xdf && cd - >/dev/null
    rm -rf $XC_BUILD_PREFIX
}

function main() {

    local cmd=$1
    local arch=$2
    local opt=$3

    echo "cmd is [$cmd]"

    if [ "x$arch" != "x" ];then
        MY_TARGET="$arch"
    else 
        MY_TARGET="$ALL_ARCHS"
    fi

    if [ "$cmd" = "lipo" ]; then
        do_lipo_all "$MY_TARGET"
    elif [ "$cmd" = "build" ]; then
        resolve_dep
        for arch in $MY_TARGET
        do
            do_compile $arch "$opt"
        done

        do_lipo_all "$MY_TARGET"
    elif [ "$cmd" = "clean" ]; then
        
        for arch in $MY_TARGET
        do
            do_clean $arch
        done
        rm -rf $XC_UNI_PROD_DIR/$LIB_NAME
        echo 'done.'
    else
            echo "Usage:"
            echo "    $0 [build|lipo|clean] [x86_64|arm64]"
            exit 1
    fi
}

main $*