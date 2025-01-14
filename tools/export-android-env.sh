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
#https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script

set -e

function init_plat_env() {
    
    if [[ -z "$XC_PLAT" ]]; then
        echo "init_plat_env must be with plat parameter."
        exit 1
    fi
    
    if [[ "$XC_PLAT" != 'macos' ]]; then
        export XC_FORCE_CROSS=true
    fi
    #on intel compile arm64 harfbuzz can't find pkg-config
    export PKG_CONFIG=$(which pkg-config)
    export XC_OTHER_CFLAGS=""
    DEFAULT_ARCHS="armv5 armv7a arm64 x86 x86_64"
    
    if [[ -z "$XC_ALL_ARCHS" ]];then
        export XC_ALL_ARCHS=$DEFAULT_ARCHS
    else
        for arch in $XC_ALL_ARCHS
        do
            validate=0
            for arch2 in $DEFAULT_ARCHS
            do
                if [[ $arch == $arch2 ]];then
                    validate=1
                fi
            done
            if [[ $validate -eq 0 ]];then
                echo "the $arch is not validate on ${XC_PLAT},you can use [$ALL_ARCHS]"
                exit 1
            fi
        done
    fi

    if [[ -z "$XC_WORKSPACE" ]];then
        export XC_WORKSPACE="${THIS_DIR}/../build"
    fi

    export XC_SRC_ROOT="${XC_WORKSPACE}/src/${XC_PLAT}"
    export XC_PRODUCT_ROOT="${XC_WORKSPACE}/product/${XC_PLAT}"
    export XC_PRE_ROOT="${XC_WORKSPACE}/pre"

    export XC_UNI_PROD_DIR="${XC_PRODUCT_ROOT}/universal"
    export XC_UNI_SIM_PROD_DIR="${XC_PRODUCT_ROOT}/universal-simulator"
    
    #common xcode configuration
    # export XC_TAGET_OS="darwin"
    # export DEBUG_INFORMATION_FORMAT=dwarf-with-dsym
    
    if [[ "$XC_VENDOR_LIBS" == "all" ]]; then
        source '../configs/default.sh'
        eval libs='$'"${XC_PLAT}_default_libs"
        export XC_VENDOR_LIBS="$libs"
    fi
}

function init_libs_pkg_config_path() {
    
    local universal_dir=
    if [[ "$XC_IS_SIMULATOR" == 1 ]];then
        universal_dir="${XC_UNI_SIM_PROD_DIR}"
    else
        universal_dir="${XC_UNI_PROD_DIR}"
    fi
    
    local pkg_cfg_dir=
    
    for dir in `[ -d ${XC_PRODUCT_ROOT} ] && find "${XC_PRODUCT_ROOT}" -type f -name "*.pc" | xargs dirname | uniq` ;
    do
        # dir is /Users/matt/GitWorkspace/ijkplayer/shell/do-compile/../build/product/ios/harfbuzz-arm64/lib/pkgconfig
        local d1=$(dirname $dir)
        local d2=$(dirname $d1)
        local d3=$(basename $d2)
        # match suffix
        if [[ "$d3" == *$_XC_ARCH ]];then
            if [[ $pkg_cfg_dir ]];then
                pkg_cfg_dir="${pkg_cfg_dir}:${dir}"
            else
                pkg_cfg_dir="${dir}"
            fi
        fi
    done
    
    for dir in `[ -d ${universal_dir} ] && find "${universal_dir}" -type f -name "*.pc" | xargs dirname | uniq` ;
    do
        if [[ $pkg_cfg_dir ]];then
            pkg_cfg_dir="${pkg_cfg_dir}:${dir}"
        else
            pkg_cfg_dir="${dir}"
        fi
    done
    
    # disabling pkg-config-path
    # https://gstreamer-devel.narkive.com/TeNagSKN/gst-devel-disabling-pkg-config-path
    # export PKG_CONFIG_LIBDIR=${sysroot}/lib/pkgconfig
    export PKG_CONFIG_LIBDIR="$pkg_cfg_dir"
    echo "PKG_CONFIG_LIBDIR:$PKG_CONFIG_LIBDIR"
}

function init_arch_env () {
    
    if [[ -z "$XC_PLAT" ]]; then
        echo "XC_PLAT can't be nil."
        exit 1
    fi
    
    export _XC_ARCH="$1"
    
    export XCRUN_PLATFORM='MacOSX'
    export MACOSX_DEPLOYMENT_TARGET=10.11
    export XC_DEPLOYMENT_TARGET="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
    export XC_IS_SIMULATOR=0
    
    # xcrun -sdk macosx clang
    export XCRUN_CC="xcrun -sdk $XCRUN_SDK clang"
    export XCRUN_CXX="xcrun -sdk $XCRUN_SDK clang++"
    
    # x86_64
    export XC_ARCH="${_XC_ARCH/_simulator/}"
    # ffmpeg-x86_64
    export XC_BUILD_NAME="${LIB_NAME}-${_XC_ARCH}"
    # ios/ffmpeg-x86_64
    export XC_BUILD_SOURCE="${XC_SRC_ROOT}/${XC_BUILD_NAME}"
    # ios/ffmpeg-x86_64
    export XC_BUILD_PREFIX="${XC_PRODUCT_ROOT}/${XC_BUILD_NAME}"
    init_libs_pkg_config_path
}

function install_depends() {
    local name="$1"
    local r=$(brew list | grep "$name")
    if [[ -z $r ]]; then
        echo "will use brew install ${name}."
        brew install "$name"
    fi
    echo "[✅] ${name}: $(eval $name --version)"
}

export -f init_libs_pkg_config_path
export -f install_depends
export -f init_plat_env
export -f init_arch_env