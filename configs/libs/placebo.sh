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

export LIB_NAME='placebo'
export LIPO_LIBS="libplacebo"
export LIB_DEPENDS_BIN="meson ninja"
# placebo depends on lcms2 and shaderc (for SPIRV), vulkan backend uses MoltenVK
export LIB_DEPENDS='lcms2 shaderc moltenvk dovi'
export GIT_LOCAL_REPO=extra/placebo
export GIT_COMMIT=v7.349.0
export REPO_DIR=placebo
export GIT_REPO_VERSION=v7.349.0

# you can export GIT_LIBPLACEB0_UPSTREAM=git@xx:yy/libplacebo.git use your mirror
if [[ "$GIT_LIBPLACEB0_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_LIBPLACEB0_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/haasn/libplacebo.git
fi
export PRE_COMPILE_TAG_MACOS=placebo-v7.349.0-260330181842
