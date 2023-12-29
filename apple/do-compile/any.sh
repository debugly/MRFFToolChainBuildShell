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

# 当前脚本所在目录
THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
source $THIS_DIR/../../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_CMD"
env_assert "XC_TARGET_ARCHS"
env_assert "LIPO_LIBS"
env_assert "LIB_NAME"
echo "XC_OPTS:$XC_OPTS"
echo "XC_FORCE_CROSS:$XC_FORCE_CROSS"
echo "===check env end==="

do_lipo_lib() {
    local LIB_FILE=$1
    local archs="$2"
    local LIPO_FLAGS=
    for arch in $archs; do
        local ARCH_LIB_FILE="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/lib/$LIB_FILE"
        if [ -f "$ARCH_LIB_FILE" ]; then
            LIPO_FLAGS="$LIPO_FLAGS $ARCH_LIB_FILE"
        else
            echo "can't find the $arch arch $LIB_FILE"
        fi
    done
    
    xcrun lipo -create $LIPO_FLAGS -output $XC_UNI_PROD_DIR/$LIB_NAME/lib/$LIB_FILE
    xcrun lipo -info $XC_UNI_PROD_DIR/$LIB_NAME/lib/$LIB_FILE
}

do_lipo_all() {
    local archs="$1"
    rm -rf $XC_UNI_PROD_DIR/$LIB_NAME
    mkdir -p $XC_UNI_PROD_DIR/$LIB_NAME/lib
    echo "lipo archs: $archs"
    for lib in $LIPO_LIBS; do
        do_lipo_lib "$lib.a" "$archs"
    done
    
    for arch in $archs; do
        local ARCH_INC_DIR="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/include"
        local ARCH_OUT_DIR="$XC_UNI_PROD_DIR/$LIB_NAME/include"
        
        if [[ -d "$ARCH_INC_DIR" && ! -d "$ARCH_OUT_DIR" ]]; then
            echo "copy include dir to $ARCH_OUT_DIR"
            cp -R "$ARCH_INC_DIR" "$ARCH_OUT_DIR"

            local ARCH_PC_DIR="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/lib/pkgconfig"
            if ls ${ARCH_PC_DIR}/*.pc >/dev/null 2>&1;then
                local UNI_PC_DIR="$XC_UNI_PROD_DIR/$LIB_NAME/lib/pkgconfig/"
                mkdir -p "$UNI_PC_DIR"
                echo "copy pkgconfig file to $UNI_PC_DIR"
                cp ${ARCH_PC_DIR}/*.pc "$UNI_PC_DIR"
                #fix prefix path
                p="$XC_UNI_PROD_DIR/$LIB_NAME"
                escaped_p=$(echo $p | sed 's/\//\\\//g')
                sed -i "" "s/^prefix=.*/prefix=$escaped_p/" "$UNI_PC_DIR/"*.pc
            fi
            break
        fi
    done
}

function export_arch_env() {
    # x86_64
    export XC_ARCH=$1
    # ffmpeg-x86_64
    export XC_BUILD_NAME="${LIB_NAME}-${XC_ARCH}"
    # ios/ffmpeg-x86_64
    export XC_BUILD_SOURCE="${XC_SRC_ROOT}/${XC_BUILD_NAME}"
    # ios/ffmpeg-x86_64
    export XC_BUILD_PREFIX="${XC_PRODUCT_ROOT}/${XC_BUILD_NAME}"
}

function do_compile() {
    export_arch_env $1
    if [ ! -d $XC_BUILD_SOURCE ]; then
        echo ""
        echo "!! ERROR"
        echo "!! Can not find $XC_BUILD_SOURCE directory for $XC_BUILD_NAME"
        echo "!! Run init-any.sh ${LIB_NAME} first"
        echo ""
        exit 1
    fi
    
    # disabling pkg-config-path
    # https://gstreamer-devel.narkive.com/TeNagSKN/gst-devel-disabling-pkg-config-path
    export PKG_CONFIG_LIBDIR=./
    # export PKG_CONFIG_LIBDIR=${sysroot}/lib/pkgconfig
    mkdir -p "$XC_BUILD_PREFIX"
    ./do-compile/$LIB_NAME.sh
}

function resolve_dep() {
    echo "[*] check depends bins: ${LIB_DEPENDS_BIN}"
    for b in ${LIB_DEPENDS_BIN}; do
        install_depends "$b"
    done
    echo "===================="
}

function do_clean() {
    export_arch_env $1
    echo "XC_BUILD_SOURCE:$XC_BUILD_SOURCE"
    cd $XC_BUILD_SOURCE && git clean -xdf && cd - >/dev/null
    rm -rf $XC_BUILD_PREFIX >/dev/null
}

function main() {
    
    local cmd="$XC_CMD"
    local archs="$XC_TARGET_ARCHS"
    
    case "$cmd" in
        'clean')
            for arch in $archs; do
                do_clean $arch
            done
            rm -rf $XC_UNI_PROD_DIR/$LIB_NAME
            echo 'done.'
        ;;
        'lipo')
            do_lipo_all "$archs"
        ;;
        'build')
            resolve_dep
            for arch in $archs; do
                init_env $arch
                do_compile $arch
                echo
            done
            
            do_lipo_all "$XC_ALL_ARCHS"
        ;;
        'rebuild')
            echo '---clean for rebuild-----------------'
            XC_CMD='clean'
            main 1>/dev/null
            echo '---build for rebuild-----------------'
            XC_CMD='build'
            main
        ;;
        *)
            echo "Unknown cmd:[$cmd]"
            echo "Maybe you want use rebuild|build|lipo|clean|"
            exit 1
        ;;
    esac
}

main
