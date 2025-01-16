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

function init_libs_pkg_config_path() {
    
    local universal_dir=
    if [[ "$MR_IS_SIMULATOR" == 1 ]];then
        universal_dir="${MR_UNI_SIM_PROD_DIR}"
    else
        universal_dir="${MR_UNI_PROD_DIR}"
    fi
    
    local pkg_cfg_dir=
    
    for dir in `[ -d ${MR_PRODUCT_ROOT} ] && find "${MR_PRODUCT_ROOT}" -type f -name "*.pc" | xargs dirname | uniq` ;
    do
        # dir is /Users/matt/GitWorkspace/ijkplayer/shell/do-compile/apple/../build/product/ios/harfbuzz-arm64/lib/pkgconfig
        local d1=$(dirname $dir)
        local d2=$(dirname $d1)
        local d3=$(basename $d2)
        # match suffix
        if [[ "$d3" == *$_MR_ARCH ]];then
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

if [[ "$MR_PLAT" == 'ios' ]]; then
    case $_MR_ARCH in
        *_simulator)
            export XCRUN_PLATFORM='iPhoneSimulator'
            export MR_DEPLOYMENT_TARGET='-mios-simulator-version-min=11.0'
            export MR_IS_SIMULATOR=1
        ;;
        'arm64')
            export XCRUN_PLATFORM='iPhoneOS'
            export MR_DEPLOYMENT_TARGET='-miphoneos-version-min=11.0'
            export MR_IS_SIMULATOR=0
        ;;
        *)
            echo "wrong arch:$_MR_ARCH for $MR_PLAT"
            exit 1
        ;;
    esac
    elif [[ "$MR_PLAT" == 'macos' ]]; then
    export XCRUN_PLATFORM='MacOSX'
    export MACOSX_DEPLOYMENT_TARGET=10.11
    export MR_DEPLOYMENT_TARGET="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
    export MR_IS_SIMULATOR=0
    elif [[ "$MR_PLAT" == 'tvos' ]]; then
    case $_MR_ARCH in
        *_simulator)
            export XCRUN_PLATFORM='AppleTVSimulator'
            export MR_DEPLOYMENT_TARGET="-mtvos-simulator-version-min=12.0"
            export MR_IS_SIMULATOR=1
        ;;
        'arm64')
            export XCRUN_PLATFORM='AppleTVOS'
            export MR_DEPLOYMENT_TARGET="-mtvos-version-min=12.0"
            export MR_IS_SIMULATOR=0
        ;;
        *)
            echo "wrong arch:$_MR_ARCH for $MR_PLAT"
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
export MR_ARCH="${_MR_ARCH/_simulator/}"
# ffmpeg-x86_64
export MR_BUILD_NAME="${LIB_NAME}-${_MR_ARCH}"
# ios/ffmpeg-x86_64
export MR_BUILD_SOURCE="${MR_SRC_ROOT}/${MR_BUILD_NAME}"
# ios/ffmpeg-x86_64
export MR_BUILD_PREFIX="${MR_PRODUCT_ROOT}/${MR_BUILD_NAME}"

init_libs_pkg_config_path

echo "MR_ARCH        : [$MR_ARCH]"
echo "MR_BUILD_NAME  : [$MR_BUILD_NAME]"
echo "MR_BUILD_SOURCE: [$MR_BUILD_SOURCE]"
echo "MR_BUILD_PREFIX: [$MR_BUILD_PREFIX]"