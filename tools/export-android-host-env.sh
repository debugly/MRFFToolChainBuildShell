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

# https://github.com/Javernaut/ffmpeg-android-maker

function install_depends() {
    local name="$1"
    local r=$(brew list | grep "$name")
    if [[ -z $r ]]; then
        echo "will use brew install ${name}."
        brew install "$name"
    fi
    echo "[✅] ${name}: $(eval $name --version)"
}

# 定义跨平台sed函数
my_sed_i() {
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS系统
        sed -i '' "$@"
    else
        # Linux系统及其他系统
        sed -i "$@"
    fi
}

export -f my_sed_i

case "$OSTYPE" in
  darwin*)  HOST_TAG="darwin-x86_64"; export -f install_depends ;;
  linux*)   HOST_TAG="linux-x86_64" ;;
  msys)
    case "$(uname -m)" in
      x86_64) HOST_TAG="windows-x86_64" ;;
      i686)   HOST_TAG="windows" ;;
    esac
  ;;
esac

if [[ $OSTYPE == "darwin"* ]]; then
  HOST_NPROC=$(sysctl -n hw.physicalcpu)
else
  HOST_NPROC=$(nproc)
fi

export MR_FORCE_CROSS=true
# The variable is used as a path segment of the toolchain path
export MR_HOST_TAG="$HOST_TAG"
# Number of physical cores in the system to facilitate parallel assembling
export MR_HOST_NPROC="$HOST_NPROC"
# for ffmpeg --target-os
export MR_TAGET_OS="android"
# 
export MR_PLAT="android"
if [[ -n "$ANDROID_NDK_HOME" ]];then
    export MR_ANDROID_NDK_HOME="$ANDROID_NDK_HOME"
elif [[ -n "$ANDROID_NDK_ROOT" ]]; then
    export MR_ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"
elif [[ -n "$ANDROID_NDK" ]]; then
    export MR_ANDROID_NDK_HOME="$ANDROID_NDK"
else
    echo "You must define ANDROID_NDK_HOME or ANDROID_NDK_ROOT or ANDROID_NDK before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
fi

export MR_NDK_REL=$(grep -m 1 -o '^## r[0-9]*.*' $MR_ANDROID_NDK_HOME/CHANGELOG.md | awk '{print $2}')

export MR_TOOLCHAIN_ROOT="$MR_ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${MR_HOST_TAG}"
export PATH="${MR_TOOLCHAIN_ROOT}/bin:$PATH"
export MR_SYS_ROOT="${MR_TOOLCHAIN_ROOT}/sysroot"

# Using Make from the Android SDK
export MR_MAKE_EXECUTABLE=${MR_ANDROID_NDK_HOME}/prebuilt/${MR_HOST_TAG}/bin/make
# Init Android plat env
export MR_DEFAULT_ARCHS="armv7a arm64 x86 x86_64"