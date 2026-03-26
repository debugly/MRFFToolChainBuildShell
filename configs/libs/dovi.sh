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

export LIB_NAME='dovi'
export LIPO_LIBS="libdovi"
export LIB_DEPENDS_BIN="rustup cargo"
export GIT_LOCAL_REPO=extra/dovi
export GIT_COMMIT=libdovi-3.3.2
export GIT_WITH_SUBMODULE=0
export REPO_DIR=dovi
export GIT_REPO_VERSION=3.3.2

if [[ "$GIT_DOVI_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_DOVI_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/quietvoid/dovi_tool.git
fiexport PRE_COMPILE_TAG_MACOS=dovi-3.3.2-260326175522
