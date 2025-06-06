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
# brew install nasm
# If you really want to compile without asm, configure with --disable-asm.

export LIB_NAME='ijkffmpeg'
export LIPO_LIBS="libavcodec libavformat libavutil libswscale libswresample libavfilter"
export LIB_DEPENDS_BIN="nasm pkg-config"
export GIT_LOCAL_REPO=extra/ijkffmpeg
export REPO_DIR=ijkffmpeg

# you can export GIT_IJKFFMPEG_UPSTREAM=git@xx:yy/FFmpeg.git use your mirror
if [[ "$GIT_IJKFFMPEG_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_IJKFFMPEG_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/bilibili/FFmpeg.git
fi

if [[ "$GIT_IJKFFMPEG_COMMIT" != "" ]] ;then
    export GIT_COMMIT="$GIT_IJKFFMPEG_COMMIT"
    export GIT_REPO_VERSION="$GIT_IJKFFMPEG_COMMIT"
else
    export GIT_COMMIT=ff4.0--ijk0.8.8--20210426--001 #origin/release/5.1
    export GIT_REPO_VERSION=4.0
fi

# pre compiled
export PRE_COMPILE_TAG_ANDROID=ijkffmpeg-4.0-250606110858
export PRE_COMPILE_TAG_TVOS=ijkffmpeg-4.0-250311090211
export PRE_COMPILE_TAG_MACOS=ijkffmpeg-4.0-250311090211
export PRE_COMPILE_TAG_IOS=ijkffmpeg-4.0-250606112050

