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

echo "=== [$0] check env begin==="
env_assert "MR_ARCH"
env_assert "MR_BUILD_NAME"
env_assert "MR_CC"
env_assert "MR_DEPLOYMENT_TARGET"
env_assert "MR_BUILD_SOURCE"
env_assert "MR_BUILD_PREFIX"
env_assert "MR_SYS_ROOT"
env_assert "MR_HOST_NPROC"
echo "MR_DEBUG:$MR_DEBUG"
echo "===check env end==="

# prepare build config
CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --openssldir=$MR_BUILD_PREFIX no-shared no-hw no-engine no-asm"

if [ "$MR_ARCH" = "x86_64" ]; then
    CFG_FLAGS="$CFG_FLAGS darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
elif [ "$MR_ARCH" = "arm64" ]; then
    CFG_FLAGS="$CFG_FLAGS darwin64-arm64-cc enable-ec_nistp_64_gcc_128"
else
    echo "unknown architecture $FF_ARCH";
    exit 1
fi

CFLAGS="-arch $MR_ARCH $MR_DEPLOYMENT_TARGET $MR_OTHER_CFLAGS"

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $MR_SYS_ROOT"
fi

#----------------------
echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE
if [ -f "./Makefile" ]; then
    echo 'reuse configure'
else
    echo 
    echo "CC: $MR_CC"
    echo "CFLAGS: $CFLAGS"
    echo "Openssl CFG: $CFG_FLAGS"
    echo 
    ./Configure $CFG_FLAGS \
        CC="$MR_CC" \
        CFLAGS="$CFLAGS" \
        CXXFLAG="$CFLAGS"
fi

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"
set +e

make build_libs -j$MR_HOST_NPROC >/dev/null
make install_dev >/dev/null
