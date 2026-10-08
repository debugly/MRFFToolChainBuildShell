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

# HarmonyOS NEXT / OpenHarmony native toolchain.
#
# The OHOS SDK ships a native/ directory with this layout:
#   $OHOS_NATIVE/llvm/bin/{clang,clang++,llvm-ar,llvm-nm,llvm-ranlib,llvm-strip,...}
#   $OHOS_NATIVE/sysroot/           (musl libc + headers)
#   $OHOS_NATIVE/build-tools/cmake/.../ohos.toolchain.cmake
#
# OHOS clang has no triple-prefixed wrappers (unlike the Android NDK):
# cross compilation is driven by `--target=aarch64-linux-ohos --sysroot=...`.
#
# Point at the native/ dir with one of: OHOS_SDK_NATIVE / OHOS_NATIVE_HOME,
# or at the SDK root with OHOS_SDK_HOME.

function install_depends() {
    local name="$1"
    if command -v "$name" &> /dev/null; then
        echo "[✅] ${name}: $(eval $name --version | head -n 1)"
        return 0
    else
        if [[ "$name" == "rustup" || "$name" == "cargo" ]]; then
            echo "will install rustup-init."
            brew install rustup-init
            rustup-init -y
            return 0
        else
            echo "will use brew install ${name}."
            brew install "$name"
        fi
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
# for ffmpeg --target-os (ohos is musl-libc linux)
export MR_TAGET_OS="linux"
#
export MR_PLAT="ohos"

# Resolve the native/ dir of the HarmonyOS SDK.
if [[ -n "$OHOS_SDK_NATIVE" ]]; then
    export MR_OHOS_NATIVE="$OHOS_SDK_NATIVE"
elif [[ -n "$OHOS_NATIVE_HOME" ]]; then
    export MR_OHOS_NATIVE="$OHOS_NATIVE_HOME"
elif [[ -n "$OHOS_SDK_HOME" ]]; then
    export MR_OHOS_NATIVE=$(find "$OHOS_SDK_HOME" -maxdepth 3 -type d -name native 2>/dev/null | head -n 1)
else
    echo "You must define OHOS_SDK_NATIVE (path to the native/ dir of the HarmonyOS SDK),"
    echo "or OHOS_NATIVE_HOME, or OHOS_SDK_HOME before starting."
    exit 1
fi

if [[ ! -d "$MR_OHOS_NATIVE/llvm/bin" ]]; then
    echo "OHOS native toolchain not found: $MR_OHOS_NATIVE/llvm/bin"
    echo "MR_OHOS_NATIVE should point at the native/ directory of the HarmonyOS SDK."
    exit 1
fi

export MR_TOOLCHAIN_ROOT="$MR_OHOS_NATIVE/llvm"
export PATH="${MR_TOOLCHAIN_ROOT}/bin:$PATH"
export MR_SYS_ROOT="$MR_OHOS_NATIVE/sysroot"

# locate ohos.toolchain.cmake (its path varies across SDK versions)
export MR_OHOS_TOOLCHAIN_FILE=$(find "$MR_OHOS_NATIVE" -name 'ohos.toolchain.cmake' 2>/dev/null | head -n 1)

# Use the build machine's make (the OHOS SDK ships no host make for macOS).
export MR_MAKE_EXECUTABLE=$(which make)
# HarmonyOS NEXT: arm64-v8a on device, x86_64 on emulator.
export MR_DEFAULT_ARCHS="arm64 x86_64"

echo "MR_OHOS_NATIVE : [$MR_OHOS_NATIVE]"
echo "MR_TOOLCHAIN_ROOT: [$MR_TOOLCHAIN_ROOT]"
echo "MR_SYS_ROOT    : [$MR_SYS_ROOT]"
echo "MR_OHOS_TOOLCHAIN_FILE: [$MR_OHOS_TOOLCHAIN_FILE]"
