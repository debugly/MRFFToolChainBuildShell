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

export LIB_NAME='ass'
export LIPO_LIBS="libass"
export LIB_DEPENDS_BIN="automake autoconf libtool"
export GIT_LOCAL_REPO=build/extra/ass
export GIT_COMMIT=0.17.1
export REPO_DIR=ass
export GIT_REPO_VERSION=0.17.1
export PRE_COMPILE_TAG='ass-0.17.1-240624163129'

# you can export GIT_ASS_UPSTREAM=git@xx:yy/ASS.git use your mirror
if [[ "$GIT_ASS_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_ASS_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/libass/libass.git
fi