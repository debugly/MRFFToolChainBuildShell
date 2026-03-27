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

export LIB_NAME='MoltenVK'
export LIPO_LIBS="libMoltenVK"
export GIT_LOCAL_REPO=extra/MoltenVK
export GIT_COMMIT=v1.4.1
export REPO_DIR=MoltenVK
export GIT_REPO_VERSION=v1.4.1

# you can export GIT_MOLTENVK_UPSTREAM=git@xx:yy/MoltenVK.git use your mirror
if [[ "$GIT_MOLTENVK_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_MOLTENVK_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/KhronosGroup/MoltenVK.git
fi

# pre compiled
export PRE_COMPILE_TAG_TVOS=
export PRE_COMPILE_TAG_MACOS=moltenvk-v1.4.1-260327175726
export PRE_COMPILE_TAG_IOS=
export PRE_COMPILE_TAG_ANDROID=
