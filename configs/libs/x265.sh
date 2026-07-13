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

export LIB_NAME='x265'
export LIPO_LIBS="libx265"
export LIB_DEPENDS_BIN="cmake nasm"
export CMAKE_TARGETS_NAME=x265-static
export GIT_LOCAL_REPO=extra/x265
export GIT_COMMIT=4.2
export REPO_DIR=x265
export GIT_REPO_VERSION=4.2

# you can export GIT_X265_UPSTREAM=git@xx:yy/x265.git use your mirror
if [[ "$GIT_X265_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_X265_UPSTREAM"
else
    export GIT_UPSTREAM=https://bitbucket.org/multicoreware/x265_git.git
fi

# pre compiled
export PRE_COMPILE_TAG_TVOS=x265-4.2-260713152852
export PRE_COMPILE_TAG_MACOS=x265-4.2-260713152852
export PRE_COMPILE_TAG_IOS=x265-4.2-260713152852
export PRE_COMPILE_TAG_ANDROID=x265-4.2-260713152852
