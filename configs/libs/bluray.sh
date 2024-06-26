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
# 
# 
# brew install nasm
# If you really want to compile without asm, configure with --disable-asm.

# LIB_DEPENDS_BIN using string because bash can't export array chttps://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script
# configure: error: Package requirements (openssl) were not met

export LIB_NAME='bluray'
export LIPO_LIBS="libbluray"
export LIB_DEPENDS_BIN="autoconf automake libtool pkg-config"
export GIT_LOCAL_REPO=build/extra/bluray
export GIT_COMMIT=1.3.4
export GIT_WITH_SUBMODULE=1
export REPO_DIR=bluray
export GIT_REPO_VERSION=1.3.4
export PRE_COMPILE_TAG='bluray-1.3.4-240605103055'

# you can export GIT_BLURAY_UPSTREAM=git@xx:yy/libbluray.git use your mirror
if [[ "$GIT_BLURAY_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_BLURAY_UPSTREAM"
else
    export GIT_UPSTREAM=https://code.videolan.org/videolan/libbluray.git
fi