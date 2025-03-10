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

export LIB_NAME='yuv'
export LIPO_LIBS="libyuv"
export LIB_DEPENDS_BIN="cmake"
export CMAKE_TARGET_NAME=yuv
export GIT_LOCAL_REPO=extra/yuv
export GIT_COMMIT=eb6e7bb
export REPO_DIR=yuv
export GIT_REPO_VERSION=stable-eb6e7bb

# you can export GIT_YUV_UPSTREAM=git@xx:yy/yuv.git use your mirror
if [[ "$GIT_YUV_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_YUV_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/debugly/libyuv.git
fi

# pre compiled
export PRE_COMPILE_TAG=yuv-stable-eb6e7bb-250226150059
export PRE_COMPILE_TAG_TVOS=yuv-stable-eb6e7bb-250226212002
export PRE_COMPILE_TAG_MACOS=yuv-stable-eb6e7bb-250226205944
export PRE_COMPILE_TAG_IOS=yuv-stable-eb6e7bb-250226175227
export PRE_COMPILE_TAG_ANDROID=yuv-stable-eb6e7bb-250310112252