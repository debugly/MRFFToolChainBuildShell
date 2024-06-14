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
source $THIS_DIR/../../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_CMD"
env_assert "LIPO_LIBS"
env_assert "LIB_NAME"
env_assert "XC_ALL_ARCHS"
echo "XC_DEBUG:$XC_DEBUG"
echo "XC_FORCE_CROSS:$XC_FORCE_CROSS"
echo "===check env end==="

do_lipo_lib() {
    local lib=$1
    local archs="$2"
    local inputs=
    local inputs_sim=

    for arch in $archs; do
        local lib_file="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/lib/${lib}.a"
        if [ -f "$lib_file" ]; then
            if [[ $arch == *simulator ]];then
                inputs_sim="$inputs_sim $lib_file"
                mkdir -p $XC_UNI_SIM_PROD_DIR/$LIB_NAME/lib
            else
                inputs="$inputs $lib_file"
                mkdir -p $XC_UNI_PROD_DIR/$LIB_NAME/lib   
            fi
        else
            echo "can't find the $arch arch $lib"
        fi
    done
    
    if [[ $inputs ]];then
        xcrun lipo -create $inputs -output $XC_UNI_PROD_DIR/$LIB_NAME/lib/${lib}.a
        xcrun lipo -info $XC_UNI_PROD_DIR/$LIB_NAME/lib/${lib}.a
    fi

    if [[ $inputs_sim ]];then
        xcrun lipo -create $inputs_sim -output $XC_UNI_SIM_PROD_DIR/$LIB_NAME/lib/${lib}.a
        xcrun lipo -info $XC_UNI_SIM_PROD_DIR/$LIB_NAME/lib/${lib}.a
    fi
}

do_lipo_all() {
    echo '----------------------'
    echo '[*] lipo'
    
    local archs="$1"
    rm -rf $XC_UNI_PROD_DIR/$LIB_NAME
    echo "lipo archs: $archs"

    for lib in $LIPO_LIBS; do
        do_lipo_lib "$lib" "$archs"
    done
    
    for arch in $archs; do

        local inc_src_dir="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/include"
        if [[ $arch == *simulator ]];then
            local uni_dir="$XC_UNI_SIM_PROD_DIR"
        else
            local uni_dir="$XC_UNI_PROD_DIR"
        fi
        
        local inc_dst_dir="$uni_dir/$LIB_NAME/include"

        if [[ -d "$inc_src_dir" ]]; then
            echo "copy include dir to $inc_dst_dir"
            cp -R "$inc_src_dir" "$inc_dst_dir"
            
            local pc_src_dir="$XC_PRODUCT_ROOT/$LIB_NAME-$arch/lib/pkgconfig"
            if ls ${pc_src_dir}/*.pc >/dev/null 2>&1;then
                local pc_dst_dir="$uni_dir/$LIB_NAME/lib/pkgconfig/"
                mkdir -p "$pc_dst_dir"
                echo "copy pkgconfig file to $pc_dst_dir"
                cp ${pc_src_dir}/*.pc "$pc_dst_dir"
                #fix prefix path
                p="$uni_dir/$LIB_NAME"
                escaped_p=$(echo $p | sed 's/\//\\\//g')
                sed -i "" "s/^prefix=.*/prefix=$escaped_p/" "$pc_dst_dir/"*.pc
            fi
        fi
    done

    echo '----------------------'
    echo '[*] make xcframework'
    
    do_make_xcframework
}

function do_make_xcframework() {
    mkdir -p "$XC_XCFRMK_DIR"
    
    for lib in $LIPO_LIBS; do
        # add macOS
        macos_lib=$XC_MACOS_PRODUCT_ROOT/universal/$LIB_NAME/lib/${lib}.a
        if [[ -f $macos_lib ]]; then
            macos_inputs="-library $macos_lib -headers $XC_MACOS_PRODUCT_ROOT/universal/$LIB_NAME/include"
        fi
        # add iOS
        ios_lib=$XC_IOS_PRODUCT_ROOT/universal/$LIB_NAME/lib/${lib}.a
        if [[ -f $ios_lib ]]; then
            ios_inputs="-library $ios_lib -headers $XC_IOS_PRODUCT_ROOT/universal/$LIB_NAME/include"
        fi
        # add iOS Simulator
        ios_sim_lib=$XC_IOS_PRODUCT_ROOT/universal-simulator/$LIB_NAME/lib/${lib}.a
        if [[ -f $ios_sim_lib ]]; then
            ios_sim_inputs="-library $ios_sim_lib -headers $XC_IOS_PRODUCT_ROOT/universal-simulator/$LIB_NAME/include"
        fi
        # add tvOS
        tvos_lib=$XC_TVOS_PRODUCT_ROOT/universal/$LIB_NAME/lib/${lib}.a
        if [[ -f $tvos_lib ]]; then
            tvos_inputs="-library $tvos_lib -headers $XC_TVOS_PRODUCT_ROOT/universal/$LIB_NAME/include"
        fi
        # add tvOS Simulator
        tvos_sim_lib=$XC_TVOS_PRODUCT_ROOT/universal-simulator/$LIB_NAME/lib/${lib}.a
        if [[ -f $tvos_sim_lib ]]; then
            tvos_sim_inputs="-library $tvos_sim_lib -headers $XC_TVOS_PRODUCT_ROOT/universal-simulator/$LIB_NAME/include"
        fi

        output=$XC_XCFRMK_DIR/${lib}.xcframework
        rm -rf "$output"
        xcodebuild -create-xcframework $macos_inputs $ios_inputs $ios_sim_inputs $tvos_inputs $tvos_sim_inputs -output "$output"
    done
}

function do_compile() {

    init_arch_env $1

    if [ ! -d $XC_BUILD_SOURCE ]; then
        echo ""
        echo "!! ERROR"
        echo "!! Can not find $XC_BUILD_SOURCE directory for $XC_BUILD_NAME"
        echo "!! Run init-any.sh ${LIB_NAME} first"
        echo ""
        exit 1
    fi
    
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
    init_arch_env $1
    
    if [[ -d $XC_BUILD_SOURCE ]];then
        echo "git clean:$XC_BUILD_SOURCE"
        cd $XC_BUILD_SOURCE
        git clean -xdf >/dev/null
        cd - >/dev/null
    fi

    if [[ -d $XC_BUILD_PREFIX ]];then
        echo "rm:$XC_BUILD_PREFIX"
        rm -rf $XC_BUILD_PREFIX >/dev/null
    fi
    
}

function main() {
    
    local cmd="$XC_CMD"
    
    case "$cmd" in
        'clean')
            for arch in $XC_ALL_ARCHS; do
                do_clean $arch
            done

            rm -rf $XC_UNI_PROD_DIR/$LIB_NAME
            echo 'done.'
        ;;
        'lipo')
            do_lipo_all "$XC_ALL_ARCHS"
        ;;
        'build')
            resolve_dep
            for arch in $XC_ALL_ARCHS; do
                do_compile $arch
                echo
            done

            do_lipo_all "$XC_ALL_ARCHS"
        ;;
        'rebuild')
            echo '---clean for rebuild-----------------'
            XC_CMD='clean'
            main #>/dev/null
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
