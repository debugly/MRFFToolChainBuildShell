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

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

echo "----------------------"
echo "[*] fetch dependencies for $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE
if [ -d "External" ]; then
    echo "dependencies already exist"
else
    if [ -f "./fetchDependencies" ]; then
        echo "fetching dependencies..."
        chmod +x ./fetchDependencies
        ./fetchDependencies
    else
        echo "fetchDependencies script not found, trying with CMake..."
    fi
fi

cd "$THIS_DIR"

pf=
dest=
scheme_suffix=
arch_param=
if [[ "$MR_PLAT" == 'ios' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64'
        dest='iOS Simulator'
        arch_param='arm64'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR64'
        dest='iOS Simulator'
        arch_param='x86_64'
    else
        pf='OS64'
        dest='iOS'
        arch_param='arm64'
    fi
    scheme_suffix='iOS only'
    export MR_DEPLOYMENT_TARGET_VER=14.0
elif [[ "$MR_PLAT" == 'tvos' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        pf='SIMULATORARM64_TVOS'
        dest='tvOS Simulator'
        arch_param='arm64'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        pf='SIMULATOR_TVOS'
        dest='tvOS Simulator'
        arch_param='x86_64'
    else
        pf='TVOS'
        dest='tvOS'
        arch_param='arm64'
    fi
    scheme_suffix='tvOS only'
    export MR_DEPLOYMENT_TARGET_VER=14.0
elif [[ "$MR_PLAT" == 'macos' ]];then
    if [[ $_MR_ARCH == 'arm64' ]];then
        pf='MAC_ARM64'
        arch_param='arm64'
    elif [[ $_MR_ARCH == 'x86_64' ]];then
        pf='MAC'
        arch_param='x86_64'
    fi
    dest='macOS'
    scheme_suffix='macOS only'
    export MR_DEPLOYMENT_TARGET_VER=11.0
fi

xc_proj="MoltenVKPackaging.xcodeproj"
scheme="MoltenVK Package ($scheme_suffix)"

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "[*] PLATFORM: $pf"
echo "[*] destination: $dest"
echo "[*] deployment target: $MR_DEPLOYMENT_TARGET_VER"
echo "----------------------"

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "[*] arch: $arch_param"
echo "----------------------"

mkdir -p "$MR_BUILD_PREFIX/lib"

xcodebuild -project "$MR_BUILD_SOURCE/$xc_proj" \
    -scheme "$scheme" \
    -destination "generic/platform=$dest" \
    -configuration Release \
    -parallelizeTargets \
    ONLY_ACTIVE_ARCH=YES \
    ARCHS="$arch_param" \
    CODE_SIGNING_ALLOWED=NO \
    build || true

dd_dir=$(find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -type d -name "MoltenVKPackaging-*" 2>/dev/null | head -1)/Build/Products/Release

if [[ -f "$dd_dir/libMoltenVK.a" ]]; then
    cp "$dd_dir/libMoltenVK.a" "$MR_BUILD_PREFIX/lib/"
    echo "Copied libMoltenVK.a to $MR_BUILD_PREFIX/lib/"
else
    echo "libMoltenVK.a not found in $dd_dir"
    exit 1
fi

alt_header_dir="$MR_BUILD_SOURCE/MoltenVK/include"
if [[ -d "$alt_header_dir" ]]; then
    mkdir -p "$MR_BUILD_PREFIX/include"
    # -L: follow symbolic links, copy actual files instead of symlinks
    # This is needed because the source includes symlinks to External dependencies
    cp -RL "$alt_header_dir"/* "$MR_BUILD_PREFIX/include/"
    echo "Copied headers from source to $MR_BUILD_PREFIX/include/"
fi

vulkan_headers="$MR_BUILD_SOURCE/External/Vulkan-Headers/include/vulkan"
if [[ -d "$vulkan_headers" ]]; then
    mkdir -p "$MR_BUILD_PREFIX/include/vulkan"
    cp -RL "$vulkan_headers"/* "$MR_BUILD_PREFIX/include/vulkan/"
    echo "Copied Vulkan headers to $MR_BUILD_PREFIX/include/vulkan/"
fi

vk_video_headers="$MR_BUILD_SOURCE/External/Vulkan-Headers/include/vk_video"
if [[ -d "$vk_video_headers" ]]; then
    mkdir -p "$MR_BUILD_PREFIX/include/vk_video"
    cp -RL "$vk_video_headers"/* "$MR_BUILD_PREFIX/include/vk_video/"
    echo "Copied vk_video headers to $MR_BUILD_PREFIX/include/vk_video/"
fi
