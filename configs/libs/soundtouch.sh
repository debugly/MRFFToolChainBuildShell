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

export LIB_NAME='soundtouch'
export LIPO_LIBS="libsoundtouch"
export LIB_DEPENDS_BIN="cmake"
export CMAKE_TARGETS_NAME=SoundTouch
export GIT_LOCAL_REPO=extra/soundtouch
export REPO_DIR=soundtouch
export GIT_COMMIT=2.4.0
export GIT_REPO_VERSION=2.4.0
export PATCH_DIR=soundtouch

# you can export GIT_SOUNDTOUCH_UPSTREAM=git@xx:yy/soundtouch.git use your mirror
if [[ "$GIT_SOUNDTOUCH_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_SOUNDTOUCH_UPSTREAM"
else
    export GIT_UPSTREAM=https://codeberg.org/soundtouch/soundtouch.git
fi

# pre compiled
export PRE_COMPILE_TAG_TVOS=soundtouch-2.4.0-260228135702
export PRE_COMPILE_TAG_MACOS=soundtouch-2.4.0-260228135702
export PRE_COMPILE_TAG_IOS=soundtouch-2.4.0-260228135702
export PRE_COMPILE_TAG_ANDROID=soundtouch-2.4.0-260228135702
