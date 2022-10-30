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

# ./init-any.sh ios
# ./init-any.sh macos
# ./init-any.sh all
# ./init-any.sh ios "ffmpeg"
# ./init-any.sh ios "ffmpeg opus"
# ./init-any.sh ios "ffmpeg opus libyuv"
# ./init-any.sh ios all x86_64

PLAT=$1
LIBS=$2
ARCH=$3

set -e

cd $(dirname "$0")
c_dir="$PWD"

function usage()
{
    echo " useage:"
    echo " $0 [ios,macos,all] [all|fdk-aac|ffmpeg|lame|libyuv|openssl|opus|x264|bluray] [all,arm64,x86_64]"
}

if [[ "$SKIP_PULL_BASE" ]];then
    echo "SKIP_PULL_BASE env recognized"
fi

if [[ "$SKIP_FFMPEG_PATHCHES" ]];then
    echo "SKIP_FFMPEG_PATHCHES env recognized"
fi

if [[ "x$LIBS" == "x" || "$LIBS" == "all" ]]; then
    LIBS=$(ls init-cfgs)
fi

if [[ "$PLAT" == 'ios' || "$PLAT" == 'macos' || "$PLAT" == 'all' ]]; then
    for lib in $LIBS
    do
        echo "===[init $lib]===================="
        $c_dir/tools/init-repo.sh "$c_dir/init-cfgs/$lib" "$PLAT" "$ARCH"
        echo "===================================="
    done
else
    usage
fi