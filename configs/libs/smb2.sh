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
# brew install nasm
# If you really want to compile without asm, configure with --disable-asm.

# LIB_DEPENDS_BIN using string because bash can't export array chttps://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script
# configure: error: Package requirements (openssl) were not met

export LIB_NAME='smb2'
export LIPO_LIBS="libsmb2"
export LIB_DEPENDS_BIN="cmake"
export CMAKE_TARGETS_NAME=smb2
export GIT_LOCAL_REPO=extra/smb2
export GIT_COMMIT=libsmb2-6.2
export REPO_DIR=smb2
export GIT_REPO_VERSION=6.2
export PATCH_DIR=smb2-6.2

# you can export GIT_SMB2_UPSTREAM=git@xx:yy/libsmb2.git use your mirror
if [[ "$GIT_SMB2_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_SMB2_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/sahlberg/libsmb2.git
fi

# pre compiled
export PRE_COMPILE_TAG_TVOS=smb2-6.2-250226212919
export PRE_COMPILE_TAG_MACOS=smb2-6.2-250625141918
export PRE_COMPILE_TAG_IOS=smb2-6.2-250226180157
export PRE_COMPILE_TAG_ANDROID=smb2-6.2-250310113032
