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

export LIB_NAME='fribidi'
export LIPO_LIBS="libfribidi"
export LIB_DEPENDS_BIN="meson pkg-config"
export GIT_LOCAL_REPO=extra/fribidi
export GIT_COMMIT=v1.0.16
export REPO_DIR=fribidi
export GIT_REPO_VERSION=1.0.16

# you can export GIT_FRIBIDI_UPSTREAM=git@xx:yy/FRIBIDI.git use your mirror
if [[ "$GIT_FRIBIDI_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_FRIBIDI_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/fribidi/fribidi.git
fi

# pre compiled
export PRE_COMPILE_TAG=fribidi-1.0.16-250225223849
