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

set -e

# 当前脚本所在目录
THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

function parse_path()
{
    SHELL_ROOT_DIR=$(cd ".."; pwd)
    local p="$1"
    if [[ $p == /* ]]; then
        echo $(cd "$p"; pwd)
    else
        echo $(mkdir -p "$SHELL_ROOT_DIR/$p";cd "$SHELL_ROOT_DIR/$p"; pwd)
    fi
}

function usage()
{
cat << EOF
usage: ./main.sh init [options]

Clone vendor library git repository,Checkout specify commit,Apply patches

OPTIONS:
    -p                   Specify platform (ios,macos,tvos), can't be nil
    -a                   Specify archs (x86_64,arm64,x86_64_simulator,arm64_simulator,all) all="x86_64,arm64,x86_64_simulator,arm64_simulator"
    -l                   Specify which libs need init (all|libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
    -s                   Specify workspace dir
    --help               Show help banner of init command
    --skip-pull-base     Skip pull base repo
    --skip-patches       Skip apply FFmpeg patches
EOF
}

if [[ -z "$1" ]];then
    usage
    exit 1
fi

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p)
            shift
            XC_PLAT="$1"
            if [[ "$XC_PLAT" != 'ios' && "$XC_PLAT" != 'macos' && "$XC_PLAT" != 'tvos' ]]; then
                echo "plat must be: [ios|macos|tvos]"
                exit 1
            fi
        ;;
        -a)
            shift
            XC_ALL_ARCHS="$1"
        ;;
        -l)
            shift
            LIBS="$1"
        ;;
        -s)
            shift
            SOURCE_DIR=$(parse_path "$1")
        ;;
        --help)
            usage
            exit 1
        ;;
        --skip-pull-base)
            export SKIP_PULL_BASE=1
        ;;
        --skip-patches)
            export SKIP_FFMPEG_PATHCHES=1
        ;;
        **)
            echo "unkonwn option:$1"
        ;;
    esac
    shift
done

if [[ -z "$LIBS" ]];then
    echo "libs can't be nil, use -l specify libs"
    exit 1
fi

if [[ -z "$XC_PLAT" ]];then
    echo "platform can't be nil, use -p specify platform"
    exit 1
fi


export XC_PLAT
export XC_ALL_ARCHS
export XC_VENDOR_LIBS="$LIBS"

if [[ $SOURCE_DIR ]];then
    export XC_WORKSPACE=$SOURCE_DIR
    echo "XC_WORKSPACE:$XC_WORKSPACE"
fi

source '../tools/export-plat-env.sh'
init_plat_env

echo '------------------------------------------'
echo "XC_PLAT         : [$XC_PLAT]"
echo "XC_VENDOR_LIBS  : [$XC_VENDOR_LIBS]"
echo "XC_ALL_ARCHS    : [$XC_ALL_ARCHS]"
echo '------------------------------------------'

echo "=== will init source code repo==="
for lib in $XC_VENDOR_LIBS
do
    echo "===[init $lib]===================="
    [[ ! -f "../configs/libs/${lib}.sh" ]] && (echo "❌$lib config not exist,init will stop.";exit 1;)
    source "../configs/libs/${lib}.sh"
    ./init-repo.sh
    echo "===================================="
done
echo "=== init source code repo done==="