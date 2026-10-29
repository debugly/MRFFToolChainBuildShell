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
# Local test library; no remote source repository is required.
export LIB_NAME='test'
export LIPO_LIBS="libtest"
export LIB_DEPENDS_BIN="pkg-config"
export LOCAL_SOURCE_DIR='../../sources/test'
export REPO_DIR=test
export GIT_COMMIT=local
export GIT_REPO_VERSION=1.4

# pre compiled
export PRE_COMPILE_TAG_ANDROID=test-1.4-261029112413
export PRE_COMPILE_TAG_TVOS=test-1.4-261029112413
export PRE_COMPILE_TAG_MACOS=test-1.4-261029112413
export PRE_COMPILE_TAG_IOS=test-1.4-261029112413
export PRE_COMPILE_TAG_OHOS=test-1.4-261029112413
