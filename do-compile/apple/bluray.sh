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

echo "=== [$0] check env begin==="
env_assert "MR_ARCH"
env_assert "MR_PLAT"
env_assert "MR_BUILD_NAME"
env_assert "XCRUN_CC"
env_assert "MR_DEPLOYMENT_TARGET"
env_assert "MR_BUILD_SOURCE"
env_assert "MR_BUILD_PREFIX"
env_assert "XCRUN_SDK_PATH"
env_assert "MR_HOST_NPROC"
echo "MR_DEBUG:$MR_DEBUG"
echo "MR_FORCE_CROSS:$MR_FORCE_CROSS"
echo "MR_OTHER_CFLAGS:$MR_OTHER_CFLAGS"
echo "===check env end==="

if [[ "$MR_DEBUG" == "debug" ]];then
    export MR_OTHER_CFLAGS="${MR_OTHER_CFLAGS} -g"
else
    export MR_OTHER_CFLAGS="${MR_OTHER_CFLAGS} -Os"
fi

# prepare build config
CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --disable-shared --disable-dependency-tracking --disable-silent-rules --disable-bdjava-jar --without-freetype --without-fontconfig --disable-doxygen-doc --disable-examples"
CFLAGS="-arch $MR_ARCH $MR_DEPLOYMENT_TARGET $MR_OTHER_CFLAGS"

if [[ "$MR_DEBUG" == "debug" ]];then
   CFG_FLAGS="${CFG_FLAGS} use_examples=yes --disable-optimizations"
fi

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $XCRUN_SDK_PATH"
    # $MR_ARCH-apple-darwin
    CFG_FLAGS="$CFG_FLAGS --host=$MR_ARCH-apple-$MR_PLAT --with-sysroot=$XCRUN_SDK_PATH"
fi

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

# use system xml2 lib
export LIBXML2_CFLAGS=$(xml2-config --prefix=${XCRUN_SDK_PATH}/usr --cflags)
export LIBXML2_LIBS=$(xml2-config --prefix=${XCRUN_SDK_PATH}/usr --libs)

cd $MR_BUILD_SOURCE

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

make install -j$MR_HOST_NPROC
# system xml2 lib has no pc file,when compile ffmepg, pkg-config can't find the private xml2 lib
echo "mv private xml lib to system"

pc_file="$MR_BUILD_PREFIX/lib/pkgconfig/libbluray.pc"
# rm line 'Requires.private'
sed -i "" '/Requires.private/d' "$pc_file"
# find line number
n=$(grep -n 'Libs.private' "$pc_file" | cut -d: -f1)
xml_lib=$(echo $(xml2-config --libs) | awk '{len=split($0,a," "); for(n=2;n<=len;n++)printf " %s",a[n]}')
# line n append " -lxml2 -lz -lpthread -licucore -lm"
sed -i "" "$n s/$/&$xml_lib/" "$pc_file"