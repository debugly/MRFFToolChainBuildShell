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
export LIB_NAME='udfread'
export LIPO_LIBS="libudfread"
export LIB_DEPENDS_BIN="meson ninja pkg-config"
export GIT_LOCAL_REPO=extra/udfread
export GIT_COMMIT=1.2.0
export REPO_DIR=udfread
export GIT_REPO_VERSION=1.2.0
export GIT_UPSTREAM="${GIT_UDFREAD_UPSTREAM:-https://code.videolan.org/videolan/libudfread.git}"
export PRE_COMPILE_TAG_IOS=udfread-1.2.0-261117162100
export PRE_COMPILE_TAG_MACOS=udfread-1.2.0-261117162100
export PRE_COMPILE_TAG_TVOS=udfread-1.2.0-261117162100
export PRE_COMPILE_TAG_ANDROID=udfread-1.2.0-261117162100
export PRE_COMPILE_TAG_OHOS=udfread-1.2.0-261117162100
