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
export LIB_NAME='dav1d'
export LIPO_LIBS="libdav1d"
export LIB_DEPENDS_BIN="meson ninja nasm"
export GIT_LOCAL_REPO=build/extra/dav1d
export GIT_COMMIT=1.3.0
export GIT_WITH_SUBMODULE=0
export REPO_DIR=dav1d
export GIT_REPO_VERSION=1.3.0
export PRE_COMPILE_TAG=dav1d-1.3.0-240628161457

# you can export GIT_DAV1D_UPSTREAM=git@xx:yy/dav1d.git use your mirror
if [[ "$GIT_DAV1D_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_DAV1D_UPSTREAM"
else
    export GIT_UPSTREAM=https://code.videolan.org/videolan/dav1d.git
fi
