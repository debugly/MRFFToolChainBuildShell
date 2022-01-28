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

echo '================='
echo "xcode version:"
echo $(xcodebuild -version)
echo '================='

function init_env () {
    
    case $1 in
        'x86_64')
            export XCRUN_PLATFORM='iPhoneSimulator'
            export XC_DEPLOYMENT_TARGET='-mios-simulator-version-min=9.0'
        ;;
        'arm64')
            export XCRUN_PLATFORM='iPhoneOS'
            export XC_DEPLOYMENT_TARGET='-miphoneos-version-min=9.0'
        ;;
    esac

    #common xcode configuration
    export XC_TAGET_OS="darwin"
    export DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

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

export -f init_env
