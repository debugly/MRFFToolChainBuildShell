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

export LIB_NAME='fontconfig'
export LIPO_LIBS="libfontconfig"
export LIB_DEPENDS_BIN="meson pkg-config"
export GIT_LOCAL_REPO=extra/fontconfig
export GIT_COMMIT=2.16.0
export REPO_DIR=fontconfig
export GIT_REPO_VERSION=2.16.0

# you can export GIT_FONTCONFIG_UPSTREAM=git@xx:yy/fontconfig.git use your mirror
if [[ "$GIT_FONTCONFIG_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_FONTCONFIG_UPSTREAM"
else
    export GIT_UPSTREAM=https://gitlab.freedesktop.org/fontconfig/fontconfig.git
fi

# pre compiled
export PRE_COMPILE_TAG=fontconfig-2.16.0-250226074147
export PRE_COMPILE_TAG_ANDROID=fontconfig-2.16.0-250310111812
