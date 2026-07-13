#!/usr/bin/env bash
#
# Copyright (C) 2021 Matt Reach<qianlongxu@gmail.com>
#
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

CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --enable-static --enable-pic --disable-cli --disable-shared"

host_arch="$MR_ARCH"
if [[ "$MR_ARCH" == "arm64" ]]; then
    host_arch="aarch64"
fi

if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" || "$MR_PLAT" == "ios" || "$MR_PLAT" == "tvos" ]]; then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    CFG_FLAGS="$CFG_FLAGS --host=$host_arch-apple-darwin"
fi

if [[ "$MR_IS_SIMULATOR" == "1" ]]; then
    CFG_FLAGS="$CFG_FLAGS --disable-asm"
fi

cd "$MR_BUILD_SOURCE"

export CC="$MR_CC"
export CFLAGS="$MR_DEFAULT_CFLAGS"
export LDFLAGS="$MR_DEFAULT_CFLAGS"

./configure $CFG_FLAGS

make install -j$MR_HOST_NPROC
