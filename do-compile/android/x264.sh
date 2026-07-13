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

CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --enable-pic --enable-static --disable-shared --disable-cli"

host=
if [[ "$_MR_ARCH" == "armv7a" ]]; then
    host="arm-linux"
elif [[ "$_MR_ARCH" == "arm64" ]]; then
    host="aarch64-linux"
elif [[ "$_MR_ARCH" == "x86" ]]; then
    host="i686-linux"
elif [[ "$_MR_ARCH" == "x86_64" ]]; then
    host="x86_64-linux"
fi

CFG_FLAGS="$CFG_FLAGS --host=$host"

if [[ "$_MR_ARCH" == "x86" || "$_MR_ARCH" == "x86_64" ]]; then
    CFG_FLAGS="$CFG_FLAGS --disable-asm"
fi

cd "$MR_BUILD_SOURCE"

export CC="$MR_TRIPLE_CC"
export AR="$MR_AR"
export RANLIB="$MR_RANLIB"
export STRIP="$MR_STRIP"

./configure $CFG_FLAGS --sysroot="$MR_SYS_ROOT" --cross-prefix="${MR_TOOLCHAIN_ROOT}/bin/llvm-"

make install -j$MR_HOST_NPROC
