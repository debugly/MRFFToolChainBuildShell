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
source ../tools/env_assert.sh

echo "=== [$0] check env begin==="
env_assert "XC_ARCH"
env_assert "XC_BUILD_NAME"
env_assert "XCRUN_CC"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XCRUN_SDK_PATH"
env_assert "XC_THREAD"
echo "XC_DEBUG:$XC_DEBUG"
echo "===check env end==="

if [[ "$XC_DEBUG" == "debug" ]];then
    export XC_OTHER_CFLAGS="${XC_OTHER_CFLAGS} -g"
else
    export XC_OTHER_CFLAGS="${XC_OTHER_CFLAGS} -Os"
fi

# prepare build config --silent
CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --disable-dependency-tracking --disable-shared --enable-silent-rules --disable-fontconfig --enable-coretext"
CFLAGS="-arch $XC_ARCH $XC_DEPLOYMENT_TARGET $XC_OTHER_CFLAGS"

# for cross compile
if [[ $(uname -m) != "$XC_ARCH" || "$XC_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $XCRUN_SDK_PATH"
    CFG_FLAGS="$CFG_FLAGS --host=$XC_ARCH-apple-darwin --with-sysroot=$XCRUN_SDK_PATH"
fi

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

cd $XC_BUILD_SOURCE


function check_lib()
{
    local lib=$1
    pkg-config --libs $lib --silence-errors >/dev/null || not_found=$?

    if [[ $not_found -eq 0 ]];then
        echo "[✅] check $lib"
    else
        echo "[❌] check $lib"
    fi
}

echo "--check denpendencies--------------------"
check_lib 'freetype2'
check_lib 'fribidi'
check_lib 'harfbuzz'
check_lib 'libunibreak'
echo "----------------------"

echo
echo "CC: $XCRUN_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "CFLAGS: $CFLAGS"
echo

if [[ -f 'configure' ]]; then
    echo "reuse configure"
else
    echo "auto generate configure"
    ./autogen.sh 1>/dev/null

    ./configure $CFG_FLAGS \
    CC="$XCRUN_CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$CFLAGS"
fi

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make install -j$XC_THREAD 1>/dev/null