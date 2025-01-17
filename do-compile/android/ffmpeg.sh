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

set -e

error_handler() {
    echo "An error occurred!"
    tail -n20 ${MR_BUILD_SOURCE}/ffbuild/config.log
}

trap 'error_handler' ERR

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

# ffmpeg config options
source $THIS_DIR/../../configs/ffconfig/module.sh
source $THIS_DIR/../../configs/ffconfig/auto-detect-third-libs.sh

CFG_FLAGS="$COMMON_FF_CFG_FLAGS"
CFG_FLAGS="$CFG_FLAGS $THIRD_CFG_FLAGS"

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]]; then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFG_FLAGS="$CFG_FLAGS --sysroot=$MR_SYS_ROOT"
    CFG_FLAGS="$CFG_FLAGS --enable-cross-compile"
fi


# Android 15 with 16 kb page size support
# https://developer.android.com/guide/practices/page-sizes#compile-r27
EXTRA_LDFLAGS="-Wl,-z,max-page-size=16384"


C_FLAGS="$MR_OTHER_CFLAGS"
LDFLAGS=$EXTRA_LDFLAGS


echo "----------------------"
echo "[*] configure"

if [[ ! -d $MR_BUILD_SOURCE ]]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find $MR_BUILD_SOURCE directory for $MR_BUILD_NAME"
    echo "!! Run 'init-*.sh' first"
    echo ""
    exit 1
fi

cd $MR_BUILD_SOURCE

if [[ -f "./config.h" ]]; then
    echo 'reuse configure'
else

    echo
    echo "CC: ${MR_TRIPLE_CC}"
    echo
    echo "CFLAGS: $C_FLAGS"
    echo
    echo "LDFLAGS:$LDFLAGS"
    echo
    echo "FF_CFG_FLAGS: $CFG_FLAGS"
    echo

    ./configure \
        $CFG_FLAGS \
        --cc=${MR_TRIPLE_CC} \
        --ld=${MR_TRIPLE_CC} \
        --as=${MR_TRIPLE_CC} \
        --ar=${MR_AR} \
        --nm=${MR_NM} \
        --strip=${MR_STRIP} \
        --ranlib=${MR_RANLIB} \
        --extra-cflags="$C_FLAGS" \
        --extra-cxxflags="$C_FLAGS" \
        --extra-ldflags="$LDFLAGS" \
        --pkg-config=${MR_PKG_CONFIG_EXECUTABLE}
fi

#----------------------
echo "----------------------"
echo "[*] compile"

make -j$MR_HOST_NPROC >/dev/null

echo "----------------------"
echo "[*] install"

cp config.* $MR_BUILD_PREFIX
make install >/dev/null
mkdir -p $MR_BUILD_PREFIX/include/libffmpeg
cp -f config.h $MR_BUILD_PREFIX/include/libffmpeg/
cp -f config_components.h $MR_BUILD_PREFIX/include/libffmpeg/
# copy private header for ffmpeg-kit.
cp -f $MR_BUILD_SOURCE/libavutil/getenv_utf8.h $MR_BUILD_PREFIX/include/libavutil/
cp -f $MR_BUILD_SOURCE/libavutil/internal.h $MR_BUILD_PREFIX/include/libavutil/
cp -f $MR_BUILD_SOURCE/libavutil/libm.h $MR_BUILD_PREFIX/include/libavutil/
cp -f $MR_BUILD_SOURCE/libavutil/attributes_internal.h $MR_BUILD_PREFIX/include/libavutil/
cp -f $MR_BUILD_SOURCE/libavcodec/mathops.h $MR_BUILD_PREFIX/include/libavcodec/

mkdir -p $MR_BUILD_PREFIX/include/libavcodec/x86/
cp -f $MR_BUILD_SOURCE/libavcodec/x86/mathops.h $MR_BUILD_PREFIX/include/libavcodec/x86/
mkdir -p $MR_BUILD_PREFIX/include/libavutil/x86/
cp -f $MR_BUILD_SOURCE/libavutil/x86/asm.h $MR_BUILD_PREFIX/include/libavutil/x86/
