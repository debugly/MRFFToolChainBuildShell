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

# prepare build config
CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --disable-dependency-tracking --disable-silent-rules --disable-apidoc --enable-static --disable-shared"
CFLAGS="$MR_OTHER_CFLAGS"

if [[ "$MR_DEBUG" == "debug" ]];then
   CFG_FLAGS="${CFG_FLAGS} use_examples=yes"
fi

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $MR_SYS_ROOT"
    CFG_FLAGS="$CFG_FLAGS --host=$MR_ARCH-apple-darwin --with-sysroot=$MR_SYS_ROOT"
fi

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

cd $MR_BUILD_SOURCE

if [[ -f 'configure' ]]; then
   echo "reuse configure"
else
   echo "auto generate configure"
   autoreconf -if >/dev/null
fi


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

./configure $CFG_FLAGS

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make install -j$MR_HOST_NPROC >/dev/null