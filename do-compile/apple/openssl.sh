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

# This script is based on projects below
# https://github.com/bilibili/ijkplayer
# https://wiki.openssl.org/index.php/Compilation_and_Installation#OS_X

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"


export CROSS_TOP="$XCRUN_SDK_PLATFORM_PATH/Developer"
export CROSS_SDK=$(basename "$MR_SYS_ROOT")

if [[ "$MR_PLAT" == "ios" || "$MR_PLAT" == "tvos" ]]; then
    compiler="iphoneos-cross"
else
    if [[ "$MR_ARCH" == "x86_64" ]]; then 
        compiler="darwin64-x86_64-cc"
    else
        compiler="darwin64-arm64-cc"
    fi
fi

echo "CROSS_TOP:$CROSS_TOP"
echo "CROSS_SDK:$CROSS_SDK"
# no-hw no-asm

CFG_FLAGS="no-shared no-engine no-dynamic-engine no-static-engine \
        no-dso no-ui-console no-tests \
        --prefix=$MR_BUILD_PREFIX \
        --openssldir=$MR_BUILD_PREFIX \
        enable-ec_nistp_64_gcc_128"

if [[ "$MR_DEBUG" != "debug" ]]; then
    CFG_FLAGS="$CFG_FLAGS --release"
fi

CFG_FLAGS="$CFG_FLAGS $compiler"

# -arch $MR_ARCH
C_FLAGS="$MR_DEFAULT_CFLAGS"

# for cross compile
# if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]];then
#     echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
#     # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
#     CFLAGS="$CFLAGS -isysroot $MR_SYS_ROOT"
# fi

cd $MR_BUILD_SOURCE
if [ -f "./Makefile" ]; then
    echo 'reuse configure'
    echo "----------------------"
    echo "[*] reuse configurate"
else
    echo "----------------------"
    echo "[*] configurate"
    echo "C_FLAGS: $C_FLAGS"
    echo "Openssl CFG: $CFG_FLAGS"
    echo "----------------------"

    export CFLAGS="$C_FLAGS"
    export CXXFLAGS="$C_FLAGS"
    export LDFLAGS="$C_FLAGS"
    export CC="$MR_CC"
    
    ./Configure $CFG_FLAGS
fi

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make build_libs -j$MR_HOST_NPROC >/dev/null
make install_dev >/dev/null
