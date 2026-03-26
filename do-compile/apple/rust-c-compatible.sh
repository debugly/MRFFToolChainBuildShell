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

if ! command -v rustup &> /dev/null; then
    return 0
fi

case "$MR_PLAT" in
macos)
    rustup target add aarch64-apple-darwin x86_64-apple-darwin
    ;;
tvos)
    rustup target add aarch64-apple-tvos aarch64-apple-tvos-sim x86_64-apple-tvos
    ;;
ios)
    rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
    ;;
esac

arch_target() {
    local arch="$1"
    local plat="$2"
    case "$plat" in
    macos)
        case "$arch" in
        arm64)
            echo "aarch64-apple-darwin"
            ;;
        x86_64)
            echo "x86_64-apple-darwin"
            ;;
        *)
            echo "$arch-apple-darwin"
            ;;
        esac
        ;;
    tvos)
        case "$arch" in
        arm64)
            echo "aarch64-apple-tvos"
            ;;
        arm64_simulator)
            echo "aarch64-apple-tvos-sim"
            ;;
        x86_64_simulator)
            echo "x86_64-apple-tvos"
            ;;
        *)
            echo "$arch-apple-tvos"
            ;;
        esac
        ;;
    *)
        case "$arch" in
        arm64)
            echo "aarch64-apple-ios"
            ;;
        arm64_simulator)
            echo "aarch64-apple-ios-sim"
            ;;
        x86_64_simulator)
            echo "x86_64-apple-ios"
            ;;
        *)
            echo "$arch-apple-ios"
            ;;
        esac
        ;;
    esac
}

rust_c_build() {
    local manifest_path="$1"
    local sub_dir="$2"
    shift 2
    local extra_args="$@"

    if [[ -n "$sub_dir" && -d "${MR_BUILD_SOURCE}/${sub_dir}" ]]; then
        cd "${MR_BUILD_SOURCE}/${sub_dir}"
    fi

    local build_dir="${MR_BUILD_SOURCE}/${LIB_NAME}_build"
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"

    export CC="$MR_CC"
    export CXX="$MR_CXX"
    export CFLAGS="-fPIC $CFLAGS $MR_DEPLOYMENT_TARGET"
    export CXXFLAGS="-fPIC $CXXFLAGS"

    local build_type="release"
    if [[ "$MR_DEBUG" == "debug" ]]; then
        build_type="debug"
    fi

    local target
    target=$(arch_target "$MR_ARCH" "$MR_PLAT")

    echo "----------------------"
    echo "[*] compile $LIB_NAME"
    echo "---------------------"
    echo "CC: $MR_CC"
    echo "CFLAGS: $CFLAGS"
    echo "build_type: $build_type"
    echo "prefix: $MR_BUILD_PREFIX"
    echo "cargo target: $target"
    echo "----------------------"

    
    cargo cinstall \
        --manifest-path="$manifest_path" \
        --target="$target" \
        --prefix="$MR_BUILD_PREFIX" \
        --lib \
        --library-type=staticlib \
        --$build_type \
        --no-default-features \
        $extra_args
}
