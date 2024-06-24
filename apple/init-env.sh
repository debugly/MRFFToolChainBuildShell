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

XCRUN_DEVELOPER=`xcode-select -print-path`
if [ ! -d "$XCRUN_DEVELOPER" ]; then
    echo "xcode path is not set correctly $XCRUN_DEVELOPER does not exist (most likely because of xcode > 4.3)"
    echo "run"
    echo "sudo xcode-select -switch <xcode path>"
    echo "for default installation:"
    echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

case $XCRUN_DEVELOPER in
    *\ * )
        echo "Your Xcode path contains whitespaces, which is not supported."
        exit 1
    ;;
esac

echo $(xcodebuild -version)

function install_depends() {
    local name="$1"
    local r=$(brew list | grep "$name")
    if [[ $r != '' ]]; then
        echo "[✅] ${name} is right."
    else
        echo "will use brew install ${name}."
        brew install "$name"
    fi
}

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
    
    if [[ "$XC_PLAT" == 'ios' ]]; then
        export XC_OTHER_CFLAGS="-fembed-bitcode"
        ALL_ARCHS="arm64 arm64_simulator x86_64_simulator"
        elif [[ "$XC_PLAT" == 'macos' ]]; then
        export XC_OTHER_CFLAGS=""
        ALL_ARCHS="x86_64 arm64"
        elif [[ "$XC_PLAT" == 'tvos' ]]; then
        export XC_OTHER_CFLAGS=''
        ALL_ARCHS="arm64 arm64_simulator x86_64_simulator"
    fi
    
    if [[ -z "$XC_ALL_ARCHS" ]];then
        export XC_ALL_ARCHS=$ALL_ARCHS
    else
        for arch in $XC_ALL_ARCHS
        do
            validate=0
            for arch2 in $ALL_ARCHS
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
    
    export XC_SRC_ROOT="${THIS_DIR}/../build/src/${XC_PLAT}"
    export XC_PRODUCT_ROOT="${THIS_DIR}/../build/product/${XC_PLAT}"
    export XC_UNI_PROD_DIR="${XC_PRODUCT_ROOT}/universal"
    export XC_UNI_SIM_PROD_DIR="${XC_PRODUCT_ROOT}/universal-simulator"
    
    export XC_IOS_PRODUCT_ROOT="${THIS_DIR}/../build/product/ios"
    export XC_MACOS_PRODUCT_ROOT="${THIS_DIR}/../build/product/macos"
    export XC_TVOS_PRODUCT_ROOT="${THIS_DIR}/../build/product/tvos"
    export XC_XCFRMK_DIR="${THIS_DIR}/../build/product/xcframework"
    
    #common xcode configuration
    export XC_TAGET_OS="darwin"
    export DEBUG_INFORMATION_FORMAT=dwarf-with-dsym
}

function init_libs_pkg_config_path() {
    
    universal_dir=
    if [[ "$XC_IS_SIMULATOR" ]];then
        universal_dir="${XC_UNI_SIM_PROD_DIR}"
    else
        universal_dir="${XC_UNI_PROD_DIR}"
    fi
    
    pkg_cfg_dir=
    
    for dir in `find "${XC_PRODUCT_ROOT}" -type f -name "*.pc" | xargs dirname | uniq` ;
    do
        if [[ "$dir" =~ "$_XC_ARCH" ]];then
            if [[ $pkg_cfg_dir ]];then
                pkg_cfg_dir="${pkg_cfg_dir}:${dir}"
            else
                pkg_cfg_dir="${dir}"
            fi
        fi
    done
    
    for dir in `find "${universal_dir}" -type f -name "*.pc" | xargs dirname | uniq` ;
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
    
    if [[ "$XC_PLAT" == 'ios' ]]; then
        case $_XC_ARCH in
            *_simulator)
                export XCRUN_PLATFORM='iPhoneSimulator'
                export XC_DEPLOYMENT_TARGET='-mios-simulator-version-min=11.0'
                export XC_IS_SIMULATOR=1
            ;;
            'arm64')
                export XCRUN_PLATFORM='iPhoneOS'
                export XC_DEPLOYMENT_TARGET='-miphoneos-version-min=11.0'
            ;;
            *)
                echo "wrong arch:$_XC_ARCH for $XC_PLAT"
                exit 1
            ;;
        esac
        elif [[ "$XC_PLAT" == 'macos' ]]; then
        export XCRUN_PLATFORM='MacOSX'
        export MACOSX_DEPLOYMENT_TARGET=10.11
        export XC_DEPLOYMENT_TARGET="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
        elif [[ "$XC_PLAT" == 'tvos' ]]; then
        case $_XC_ARCH in
            *_simulator)
                export XCRUN_PLATFORM='AppleTVSimulator'
                export XC_DEPLOYMENT_TARGET="-mtvos-simulator-version-min=12.0"
                export XC_IS_SIMULATOR=1
            ;;
            'arm64')
                export XCRUN_PLATFORM='AppleTVOS'
                export XC_DEPLOYMENT_TARGET="-mtvos-version-min=12.0"
            ;;
            *)
                echo "wrong arch:$_XC_ARCH for $XC_PLAT"
                exit 1
            ;;
        esac
    fi
    
    # macosx
    export XCRUN_SDK=`echo $XCRUN_PLATFORM | tr '[:upper:]' '[:lower:]'`
    # xcrun -sdk macosx clang
    export XCRUN_CC="xcrun -sdk $XCRUN_SDK clang"
    export XCRUN_CXX="xcrun -sdk $XCRUN_SDK clang++"
    # xcrun -sdk macosx --show-sdk-platform-path
    # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform
    export XCRUN_SDK_PLATFORM_PATH=`xcrun -sdk $XCRUN_SDK --show-sdk-platform-path`
    # xcrun -sdk macosx --show-sdk-path
    # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.3.sdk
    export XCRUN_SDK_PATH=`xcrun -sdk $XCRUN_SDK --show-sdk-path`
    
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

export -f init_libs_pkg_config_path
export -f install_depends
export -f init_plat_env
export -f init_arch_env
