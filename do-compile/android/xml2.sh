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

# can't use cmake,because ios undeclared function 'getentropy'
# https://gitlab.gnome.org/GNOME/libxml2/-/issues/774#note_2174500
# ./cmake-compatible.sh "-DBUILD_SHARED_LIBS=0 -DLIBXML2_WITH_PROGRAMS=0 -DLIBXML2_WITH_ZLIB=1 -DLIBXML2_WITH_PYTHON=0 -DLIBXML2_WITH_ICONV=1"


CFLAGS="$MR_DEFAULT_CFLAGS"

# prepare build config
CFG_FLAGS="--prefix=$MR_BUILD_PREFIX"
# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $MR_SYS_ROOT"
    # aarch64-linux-android21
    CFG_FLAGS="$CFG_FLAGS --host=$MR_FF_ARCH-linux-android$MR_ANDROID_API --with-sysroot=$MR_SYS_ROOT"
fi

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE

echo 
echo "CC: $MR_TRIPLE_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "CFLAGS: $CFLAGS"
echo 

export CFLAGS="$CFLAGS"
export LDFLAGS="$CFLAGS"

export CC="$MR_TRIPLE_CC"
export CXX="$MR_TRIPLE_CXX"
export AR="$MR_AR"
export AS="$RM_AS"
export RANLIB="$MR_RANLIB"
export STRIP="$MR_STRIP"
./autogen.sh \
    $CFG_FLAGS \
    --prefix=$MR_BUILD_PREFIX \
    --enable-static --disable-shared \
    --disable-fast-install \
    --without-python \
    --without-debug \
    --with-zlib \
    --with-pic \
    --without-lzma

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make clean >/dev/null
make install -j${MR_HOST_NPROC}