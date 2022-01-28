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

CMD=$1
LIBS=$2
ARCH=$3

set -e

function usage()
{
    echo " useage:"
    echo "  $0 [build|lipo|clean] [all|fdk-aac|ffmpeg|lame|libyuv|openssl|opus|x264] [arm64|x86_64|all] "
}

function prepare_compile_env()
{
    local lib="$1"
    source compile-cfgs/"$lib"
}

if [[ "$LIBS" == "all" ]]; then
    LIBS=$(cat compile-cfgs/list.txt)
fi

if [[ -z "$ARCH" || "$ARCH" == 'all' ]]; then
    ARCH="$ALL_ARCHS"
fi

if [[ ! -z "$CMD" ]]; then

    source ./ios-env.sh
    
    for lib in $LIBS
    do
        echo "===[$CMD $lib]===================="
        prepare_compile_env "$lib"
        ./do-compile/any.sh "$CMD" "$ARCH"

        if [[ $? -eq 0 ]];then
            echo "🎉  Congrats"
            echo "🚀  ${LIB_NAME} successfully $CMD."
            echo
        fi
        echo "===================================="
    done
else
    usage
fi