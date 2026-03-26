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
echo "[*] configure $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE

cd dolby_vision

build_dir="${MR_BUILD_SOURCE}/dolby_vision_build"
rm -rf "$build_dir"
mkdir -p "$build_dir"
cd "$build_dir"

export CC="$MR_CC"
export CXX="$MR_CXX"
export CFLAGS="-fPIC $CFLAGS"
export CXXFLAGS="-fPIC $CXXFLAGS"

if [[ "$MR_DEBUG" == "debug" ]]; then
    build_type="debug"
else
    build_type="release"
fi

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "---------------------"
echo "CC: $MR_CC"
echo "CFLAGS: $CFLAGS"
echo "build_type: $build_type"
echo "prefix: $MR_BUILD_PREFIX"
echo "----------------------"

MANIFEST_PATH="${MR_BUILD_SOURCE}/dolby_vision/Cargo.toml"

arch_target() {
    local arch="$1"
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
}

target=$(arch_target "$MR_ARCH")

cargo cinstall \
    --manifest-path="$MANIFEST_PATH" \
    --target="$target" \
    --prefix="$MR_BUILD_PREFIX" \
    --lib \
    --library-type=staticlib \
    --release \
    --no-default-features \
    --features capi

echo "----------------------"
echo "[*] install $LIB_NAME"
echo "----------------------"