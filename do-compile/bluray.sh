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
env_assert "XC_PLAT"
env_assert "XC_BUILD_NAME"
env_assert "XCRUN_CC"
env_assert "XC_DEPLOYMENT_TARGET"
env_assert "XC_BUILD_SOURCE"
env_assert "XC_BUILD_PREFIX"
env_assert "XCRUN_SDK_PATH"
env_assert "XC_THREAD"
echo "XC_DEBUG:$XC_DEBUG"
echo "XC_FORCE_CROSS:$XC_FORCE_CROSS"
echo "XC_OTHER_CFLAGS:$XC_OTHER_CFLAGS"
echo "===check env end==="

if [[ "$XC_DEBUG" == "debug" ]];then
    export XC_OTHER_CFLAGS="${XC_OTHER_CFLAGS} -g"
else
    export XC_OTHER_CFLAGS="${XC_OTHER_CFLAGS} -Os"
fi

# prepare build config
CFG_FLAGS="--prefix=$XC_BUILD_PREFIX --disable-shared --disable-dependency-tracking --disable-silent-rules --disable-bdjava-jar --without-freetype --without-fontconfig --disable-doxygen-doc --disable-examples"
CFLAGS="-arch $XC_ARCH $XC_DEPLOYMENT_TARGET $XC_OTHER_CFLAGS"

if [[ "$XC_DEBUG" == "debug" ]];then
   CFG_FLAGS="${CFG_FLAGS} use_examples=yes --disable-optimizations"
fi

# for cross compile
if [[ $(uname -m) != "$XC_ARCH" || "$XC_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $XC_PLAT $XC_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $XCRUN_SDK_PATH"
    # $XC_ARCH-apple-darwin
    CFG_FLAGS="$CFG_FLAGS --host=$XC_ARCH-apple-$XC_PLAT --with-sysroot=$XCRUN_SDK_PATH"
fi

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

# use system xml2 lib
export LIBXML2_CFLAGS=$(xml2-config --prefix=${XCRUN_SDK_PATH}/usr --cflags)
export LIBXML2_LIBS=$(xml2-config --prefix=${XCRUN_SDK_PATH}/usr --libs)

cd $XC_BUILD_SOURCE

if [[ -f 'configure' ]]; then
   echo "reuse configure"
else
   echo "auto generate configure"
   ./bootstrap >/dev/null
fi

echo 
echo "CC: $XCRUN_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "CFLAGS: $CFLAGS"
echo 

export CC="$XCRUN_CC"
export CFLAGS="$CFLAGS"
export LDFLAGS="$CFLAGS"

./configure $CFG_FLAGS

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make install -j$XC_THREAD
# system xml2 lib has no pc file,when compile ffmepg, pkg-config can't find the private xml2 lib
echo "mv private xml lib to system"

pc_file="$XC_BUILD_PREFIX/lib/pkgconfig/libbluray.pc"
# rm line 'Requires.private'
sed -i "" '/Requires.private/d' "$pc_file"
# find line number
n=$(grep -n 'Libs.private' "$pc_file" | cut -d: -f1)
xml_lib=$(echo $(xml2-config --libs) | awk '{len=split($0,a," "); for(n=2;n<=len;n++)printf " %s",a[n]}')
# line n append " -lxml2 -lz -lpthread -licucore -lm"
sed -i "" "$n s/$/&$xml_lib/" "$pc_file"