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

XCODE_DEVELOPER=`xcode-select -print-path`
if [ ! -d "$XCODE_DEVELOPER" ]; then
    echo "xcode path is not set correctly $XCODE_DEVELOPER does not exist (most likely because of xcode > 4.3)"
    echo "run"
    echo "sudo xcode-select -switch <xcode path>"
    echo "for default installation:"
    echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

case $XCODE_DEVELOPER in
    *\ * )
        echo "Your Xcode path contains whitespaces, which is not supported."
        exit 1
    ;;
esac

# /Applications/Xcode.app/Contents/Developer
export MR_XCODE_DEVELOPER="$XCODE_DEVELOPER"

echo $(xcodebuild -version)

DEPLOYMENT_TARGET_KEY=
if [[ "$MR_PLAT" == 'ios' ]]; then
    export MR_DEPLOYMENT_TARGET_VER=12.0
    case $_MR_ARCH in
        *_simulator)
            export XCRUN_PLATFORM='iPhoneSimulator'
            DEPLOYMENT_TARGET_KEY='-mios-simulator-version-min'
            export MR_IS_SIMULATOR=1
        ;;
        'arm64')
            export XCRUN_PLATFORM='iPhoneOS'
            DEPLOYMENT_TARGET_KEY='-miphoneos-version-min'
            export MR_IS_SIMULATOR=0
        ;;
        *)
            echo "wrong arch:$_MR_ARCH for $MR_PLAT"
            exit 1
        ;;
    esac
elif [[ "$MR_PLAT" == 'macos' ]]; then
    export XCRUN_PLATFORM='MacOSX'
    export MACOSX_DEPLOYMENT_TARGET=10.14
    export MR_DEPLOYMENT_TARGET_VER=10.14
    DEPLOYMENT_TARGET_KEY="-mmacosx-version-min"
    export MR_IS_SIMULATOR=0
elif [[ "$MR_PLAT" == 'tvos' ]]; then
    export MR_DEPLOYMENT_TARGET_VER=12.0
    case $_MR_ARCH in
        *_simulator)
            export XCRUN_PLATFORM='AppleTVSimulator'
            DEPLOYMENT_TARGET_KEY="-mtvos-simulator-version-min"
            export MR_IS_SIMULATOR=1
        ;;
        'arm64')
            export XCRUN_PLATFORM='AppleTVOS'
            DEPLOYMENT_TARGET_KEY="-mtvos-version-min"
            export MR_IS_SIMULATOR=0
        ;;
        *)
            echo "wrong arch:$_MR_ARCH for $MR_PLAT"
            exit 1
        ;;
    esac
fi

# macosx
XCRUN_SDK=`echo $XCRUN_PLATFORM | tr '[:upper:]' '[:lower:]'`
# xcrun -sdk macosx clang
export MR_CC="xcrun -sdk $XCRUN_SDK clang"
export MR_CXX="xcrun -sdk $XCRUN_SDK clang++"
# xcrun -sdk macosx --show-sdk-platform-path
# /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform
export XCRUN_SDK_PLATFORM_PATH=`xcrun -sdk $XCRUN_SDK --show-sdk-platform-path`
# xcrun -sdk macosx --show-sdk-path
# /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.3.sdk
export MR_SYS_ROOT=`xcrun -sdk $XCRUN_SDK --show-sdk-path`

# x86_64
export MR_ARCH="${_MR_ARCH/_simulator/}"
export MR_FF_ARCH="${MR_ARCH}"

# ios/ffmpeg-x86_64
export MR_BUILD_SOURCE="${MR_SRC_ROOT}/${REPO_DIR}-${_MR_ARCH}"
# ios/fftutorial-x86_64
export MR_BUILD_PREFIX="${MR_PRODUCT_ROOT}/${LIB_NAME}-${_MR_ARCH}"
export MR_DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET_KEY}=${MR_DEPLOYMENT_TARGET_VER}"
# -arch x86_64 -mios-simulator-version-min=11.0
export MR_DEFAULT_CFLAGS="-arch $MR_ARCH $MR_INIT_CFLAGS $MR_DEPLOYMENT_TARGET -D__APPLE__"

echo "MR_ARCH          : [$MR_ARCH]"
echo "MR_BUILD_SOURCE  : [$MR_BUILD_SOURCE]"
echo "MR_BUILD_PREFIX  : [$MR_BUILD_PREFIX]"
echo "MR_DEFAULT_CFLAGS: [$MR_DEFAULT_CFLAGS]"

#
THIS_DIR=$(DIRNAME=$(dirname "${BASH_SOURCE[0]}"); cd "${DIRNAME}"; pwd)
source "$THIS_DIR/export-apple-pkg-config-dir.sh"

echo "PKG_CONFIG_LIBDIR: [$PKG_CONFIG_LIBDIR]"