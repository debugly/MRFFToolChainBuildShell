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

export THREAD_COUNT=$(sysctl -n machdep.cpu.thread_count)
export XC_USE_XCFRAMEWORK=1

echo "support thread count:$THREAD_COUNT"

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

    PLAT=$1
    if [[ -z "$PLAT" ]]; then
        echo "init_plat_env must be with plat parameter."
        exit 1
    fi

    if [[ "$PLAT" != 'macos' ]]; then
        export XC_FORCE_CROSS=true
        export PKG_CONFIG=$(which pkg-config)
    fi

    if [[ "$PLAT" == 'ios' ]]; then
        export XC_OTHER_CFLAGS="-fembed-bitcode"
        export XC_ALL_ARCHS="x86_64 arm64"
    elif [[ "$PLAT" == 'macos' ]]; then
        export XC_OTHER_CFLAGS=""
        export XC_ALL_ARCHS="x86_64 arm64"
    elif [[ "$PLAT" == 'tvos' ]]; then
        export XC_OTHER_CFLAGS=''
        export XC_ALL_ARCHS="arm64 arm64_simulator"
    fi

    export XC_SRC_ROOT="${THIS_DIR}/../build/src/${PLAT}"
    export XC_PRODUCT_ROOT="${THIS_DIR}/../build/product/${PLAT}"
    export XC_UNI_PROD_DIR="${XC_PRODUCT_ROOT}/universal"
    export XC_PLAT="$PLAT"
    
    #common xcode configuration
    export XC_TAGET_OS="darwin"
    export DEBUG_INFORMATION_FORMAT=dwarf-with-dsym
}

function init_arch_env () {
    
    if [[ -z "$XC_PLAT" ]]; then
        echo "XC_PLAT can't be nil."
        exit 1
    fi
    
    if [[ "$XC_PLAT" == 'ios' ]]; then
        case $1 in
            'x86_64')
                export XCRUN_PLATFORM='iPhoneSimulator'
                export XC_DEPLOYMENT_TARGET='-mios-simulator-version-min=11.0'
                export XC_IS_SIMULATOR=1
            ;;
            'arm64')
                export XCRUN_PLATFORM='iPhoneOS'
                export XC_DEPLOYMENT_TARGET='-miphoneos-version-min=11.0'
            ;;
        esac
    elif [[ "$XC_PLAT" == 'macos' ]]; then
        export XCRUN_PLATFORM='MacOSX'
        export MACOSX_DEPLOYMENT_TARGET=10.11
        export XC_DEPLOYMENT_TARGET="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
    elif [[ "$XC_PLAT" == 'tvos' ]]; then
        case $1 in
            'arm64_simulator')
                export XCRUN_PLATFORM='AppleTVSimulator'
                export XC_DEPLOYMENT_TARGET="-mtvos-simulator-version-min=12.0"
                export XC_IS_SIMULATOR=1
            ;;
            'arm64')
                export XCRUN_PLATFORM='AppleTVOS'
                export XC_DEPLOYMENT_TARGET="-mtvos-version-min=12.0"
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
}

export -f install_depends
export -f init_plat_env
export -f init_arch_env
