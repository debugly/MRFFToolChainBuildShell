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

# Creating a multiplatform binary framework bundle
# https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle

set -e

# 当前脚本所在目录
THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

do_lipo_lib() {
    local lib=$1
    local archs="$2"
    
    for arch in $archs; do
        local lib_dir="$MR_PRODUCT_ROOT/$LIB_NAME-$arch"
        if [ -d "$lib_dir" ]; then
            mkdir -p "$MR_UNI_PROD_DIR/$LIB_NAME"
            cp -Rf "$lib_dir" "$MR_UNI_PROD_DIR/$LIB_NAME"
        else
            echo "can't find the $arch arch $lib"
        fi
    done
}

do_lipo_all() {
    echo '----------------------'
    echo '[*] lipo'
    
    local archs="$1"
    rm -rf $MR_UNI_PROD_DIR/$LIB_NAME
    echo "lipo archs: $archs"
    
    do_lipo_lib "$lib" "$archs"
    
    echo '----------------------'
    echo 
}

function do_compile() {
    if [ ! -d $MR_BUILD_SOURCE ]; then
        echo ""
        echo "!! ERROR"
        echo "!! Can not find $MR_BUILD_SOURCE directory for $MR_BUILD_NAME"
        echo "!! Run init-any.sh ${LIB_NAME} first"
        echo ""
        exit 1
    fi
    
    mkdir -p "$MR_BUILD_PREFIX"
    ./$LIB_NAME.sh
}

function resolve_dep() {
    echo "[*] check depends bins: ${LIB_DEPENDS_BIN}"
    for b in ${LIB_DEPENDS_BIN}; do
        install_depends "$b"
    done
    echo "===================="
}

function do_clean() {

    if [[ -d $MR_BUILD_SOURCE ]];then
        echo "git clean:$MR_BUILD_SOURCE"
        cd $MR_BUILD_SOURCE
        git clean -xdf >/dev/null
        cd - >/dev/null
    fi
    
    if [[ -d $MR_BUILD_PREFIX ]];then
        echo "rm:$MR_BUILD_PREFIX"
        rm -rf $MR_BUILD_PREFIX >/dev/null
    fi
}

function main() {
    
    local cmd="$MR_CMD"
    
    case "$cmd" in
        'clean')
            for arch in $MR_ACTIVE_ARCHS; do
                export _MR_ARCH=$arch
                source $MR_SHELL_TOOLS_DIR/export-android-build-env.sh
                echo "---"
                do_clean $arch
            done
            
            rm -rf $MR_UNI_PROD_DIR/$LIB_NAME
        ;;
        'lipo')
            do_lipo_all "$MR_ACTIVE_ARCHS"
        ;;
        'build')
            resolve_dep
            for arch in $MR_ACTIVE_ARCHS; do
                export _MR_ARCH=$arch
                source $MR_SHELL_TOOLS_DIR/export-android-build-env.sh
                do_compile
                echo
            done
            do_lipo_all "$MR_ACTIVE_ARCHS"
        ;;
        'rebuild')
            echo
            echo '---clean for rebuild-----------------'
            MR_CMD='clean'
            main #>/dev/null
            echo
            echo '---build for rebuild-----------------'
            MR_CMD='build'
            main
        ;;
        *)
            echo "Unknown cmd:[$cmd]"
            echo "Maybe you want use rebuild|build|clean|"
            exit 1
        ;;
    esac
}

main