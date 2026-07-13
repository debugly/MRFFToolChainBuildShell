#! /usr/bin/env bash
#
# Copyright (C) 2021 Matt Reach<qianlongxu@gmail.com>
#
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

export LIB_NAME='x264'
export LIPO_LIBS="libx264"
export LIB_DEPENDS_BIN="nasm"
export GIT_LOCAL_REPO=extra/x264
export GIT_COMMIT=origin/master
export REPO_DIR=x264
export GIT_REPO_VERSION=master

# you can export GIT_X264_UPSTREAM=git@xx:yy/x264.git use your mirror
if [[ "$GIT_X264_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_X264_UPSTREAM"
else
    export GIT_UPSTREAM=https://code.videolan.org/videolan/x264.git
fi

# pre compiled
export PRE_COMPILE_TAG_TVOS=
export PRE_COMPILE_TAG_MACOS=
export PRE_COMPILE_TAG_IOS=
export PRE_COMPILE_TAG_ANDROID=
