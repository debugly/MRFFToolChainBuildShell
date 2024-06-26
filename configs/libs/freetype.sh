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
# LIB_DEPENDS_BIN using string because bash can't export array chttps://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script
# configure: error: Package requirements (openssl) were not met

export LIB_NAME='freetype'
export LIPO_LIBS="libfreetype"
export LIB_DEPENDS_BIN="meson cmake"
export GIT_LOCAL_REPO=build/extra/freetype
export GIT_COMMIT=VER-2-13-2
export REPO_DIR=freetype
export GIT_REPO_VERSION=2.13.2
export GIT_WITH_SUBMODULE=1
export PRE_COMPILE_TAG='freetype-2.13.2-240624160513'

# you can export GIT_FREETYPE_UPSTREAM=git@xx:yy/FREETYPE.git use your mirror
if [[ "$GIT_FREETYPE_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_FREETYPE_UPSTREAM"
else
    export GIT_UPSTREAM=https://gitlab.freedesktop.org/freetype/freetype.git
fi