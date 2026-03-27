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
set -o pipefail

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

dest=
scheme_suffix=
arch_param=
fetch_deps_arg=

if [[ "$MR_PLAT" == 'ios' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        dest='iOS Simulator'
        arch_param='arm64'
        fetch_deps_arg='--iossim'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        dest='iOS Simulator'
        arch_param='x86_64'
        fetch_deps_arg='--iossim'
    else
        dest='iOS'
        arch_param='arm64'
        fetch_deps_arg='--ios'
    fi
    scheme_suffix='iOS only'
    export MR_DEPLOYMENT_TARGET_VER=14.0
elif [[ "$MR_PLAT" == 'tvos' ]];then
    if [[ $_MR_ARCH == 'arm64_simulator' ]];then
        dest='tvOS Simulator'
        arch_param='arm64'
        fetch_deps_arg='--tvossim'
    elif [[ $_MR_ARCH == 'x86_64_simulator' ]];then
        dest='tvOS Simulator'
        arch_param='x86_64'
        fetch_deps_arg='--tvossim'
    else
        dest='tvOS'
        arch_param='arm64'
        fetch_deps_arg='--tvos'
    fi
    scheme_suffix='tvOS only'
    export MR_DEPLOYMENT_TARGET_VER=14.0
elif [[ "$MR_PLAT" == 'macos' ]];then
    if [[ $_MR_ARCH == 'arm64' ]];then
        arch_param='arm64'
    elif [[ $_MR_ARCH == 'x86_64' ]];then
        arch_param='x86_64'
    fi
    dest='macOS'
    scheme_suffix='macOS only'
    fetch_deps_arg='--macos'
    export MR_DEPLOYMENT_TARGET_VER=11.0
fi

echo "----------------------"
echo "[*] fetch dependencies for $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE
if [ -d "External/build" ]; then
    echo "dependencies already exist"
else
    if [ -f "./fetchDependencies" ]; then
        echo "fetching dependencies for $fetch_deps_arg..."
        chmod +x ./fetchDependencies
        ./fetchDependencies $fetch_deps_arg
    else
        echo "fetchDependencies script not found, trying with CMake..."
    fi
fi

cd "$THIS_DIR"

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "[*] destination: $dest"
echo "[*] deployment target: $MR_DEPLOYMENT_TARGET_VER"
echo "----------------------"

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "[*] arch: $arch_param"
echo "----------------------"

mkdir -p "$MR_BUILD_PREFIX/lib"

xcodebuild -project "$MR_BUILD_SOURCE/MoltenVKPackaging.xcodeproj" \
    -scheme "MoltenVK Package ($scheme_suffix)" \
    -destination "generic/platform=$dest" \
    -configuration Release \
    CODE_SIGNING_ALLOWED=NO \
    build

pkg_static_dir="$MR_BUILD_SOURCE/Package/Release/MoltenVK/static"
if [[ -d "$pkg_static_dir/MoltenVK.xcframework" ]]; then
    xcframework_dir="$pkg_static_dir/MoltenVK.xcframework"
    archs_dir=$(ls "$xcframework_dir/" 2>/dev/null | grep -v Info.plist | head -1)
    if [[ -n "$archs_dir" && -f "$xcframework_dir/$archs_dir/libMoltenVK.a" ]]; then
        cp "$xcframework_dir/$archs_dir/libMoltenVK.a" "$MR_BUILD_PREFIX/lib/"
        echo "Copied libMoltenVK.a from xcframework to $MR_BUILD_PREFIX/lib/"
    fi
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

echo "----------------------"
echo "[*] generate pkg-config files"
echo "----------------------"

mkdir -p "$MR_BUILD_PREFIX/lib/pkgconfig"

MOLTENVK_MAJOR=$(grep "MVK_VERSION_MAJOR" "$MR_BUILD_PREFIX/include/MoltenVK/mvk_private_api.h" | grep -oE "[0-9]+" | head -1)
MOLTENVK_MINOR=$(grep "MVK_VERSION_MINOR" "$MR_BUILD_PREFIX/include/MoltenVK/mvk_private_api.h" | grep -oE "[0-9]+" | head -1)
MOLTENVK_PATCH=$(grep "MVK_VERSION_PATCH" "$MR_BUILD_PREFIX/include/MoltenVK/mvk_private_api.h" | grep -oE "[0-9]+" | head -1)
MOLTENVK_VERSION="${MOLTENVK_MAJOR}.${MOLTENVK_MINOR}.${MOLTENVK_PATCH}"

VULKAN_VERSION="1.3.250"

cat > "$MR_BUILD_PREFIX/lib/pkgconfig/vulkan.pc" << EOF
prefix=${MR_BUILD_PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: Vulkan
Description: Vulkan loader (MoltenVK)
Version: ${VULKAN_VERSION}
Libs: -L\${libdir} -lMoltenVK
Libs.private: -framework Metal -framework Foundation -framework QuartzCore -framework IOKit -framework IOSurface -lc++
Cflags: -I\${includedir} -I\${includedir}/vulkan
EOF

cat > "$MR_BUILD_PREFIX/lib/pkgconfig/moltenvk.pc" << EOF
prefix=${MR_BUILD_PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: MoltenVK
Description: Vulkan implementation on Metal for macOS and iOS
Version: ${MOLTENVK_VERSION}
Libs: -L\${libdir} -lMoltenVK
Libs.private: -framework Metal -framework Foundation -framework QuartzCore -framework IOKit -framework IOSurface -lc++
Cflags: -I\${includedir} -I\${includedir}/vulkan -I\${includedir}/MoltenVK
Requires: vulkan
EOF

echo "Generated vulkan.pc (${VULKAN_VERSION}) and moltenvk.pc (${MOLTENVK_VERSION})"
