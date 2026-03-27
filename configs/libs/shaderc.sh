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

export LIB_NAME='shaderc'
export LIPO_LIBS="libshaderc_combined"
export LIB_DEPENDS_BIN="cmake"
export GIT_LOCAL_REPO=extra/shaderc
export GIT_COMMIT=v2025.3
export REPO_DIR=shaderc
export GIT_REPO_VERSION=v2025.3

# macOS deployment target must be 11.0+ for std::filesystem in glslang
export MR_DEPLOYMENT_TARGET_VER_MACOS=11.0

# you can export GIT_SHADERC_UPSTREAM=git@xx:yy/shaderc.git use your mirror
if [[ "$GIT_SHADERC_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_SHADERC_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/google/shaderc.git
fi
export PRE_COMPILE_TAG_MACOS=shaderc-v2025.3-260327181828
