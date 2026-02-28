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
export CMAKE_TARGETS_NAME=yuv
export GIT_LOCAL_REPO=extra/yuv

# ✅----------------
# 4e8a843b 2024年4月1日 使用单个.a
# f94b8cf7 2024年4月8日 使用单个.a
# ❌----------------
# b5a18f9d 2024年12月30日 使用多个.a
# efd164d6 2024年6月18日  使用多个.a
# 3af6cafe 2024年4月11日  使用多个.a
# e52007ef 2024年4月9日 中间编译报错

export GIT_COMMIT=f94b8cf7
export REPO_DIR=yuv
export GIT_REPO_VERSION=main-f94b8cf7
export PATCH_DIR=yuv

# you can export GIT_YUV_UPSTREAM=git@xx:yy/yuv.git use your mirror
if [[ "$GIT_YUV_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_YUV_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/debugly/libyuv.git
fi

# pre compiled
export PRE_COMPILE_TAG_TVOS=yuv-main-f94b8cf7-260228135452
export PRE_COMPILE_TAG_MACOS=yuv-main-f94b8cf7-260228135452
export PRE_COMPILE_TAG_IOS=yuv-main-f94b8cf7-260228135452
export PRE_COMPILE_TAG_ANDROID=yuv-main-f94b8cf7-260228135452