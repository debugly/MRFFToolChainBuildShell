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

function usage()
{
cat << EOF
usage: ./apple/compile-any.sh [options]

compile ijkplayer using libs for iOS and macOS and tvOS，such as libass、ffmpeg...

OPTIONS:
   -h            Show some help
   -p            Specify platform (ios,macos,tvos)
   -c            Specify cmd (build,clean,rebuild,lipo) rebuild=clean+build
   -a            Specify archs (x86_64,arm64,x86_64_simulator,arm64_simulator,all) all="x86_64,arm64,x86_64_simulator,arm64_simulator"
   -l            Specify which libs need 'cmd' (all|libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg)
   -d            Enable debug mode (disable by default)
   -t            Force number of cores to be used
EOF
}

while getopts "hp:c:a:l:dt:" opt
do
    #echo "opt:$opt,OPTIND:[$OPTIND],OPTARG:[$OPTARG]"
    case $opt in
        h)
            usage
        ;;
        p)
            XC_PLAT="$OPTARG"
            if [[ "$XC_PLAT" != 'ios' && "$XC_PLAT" != 'macos' && "$XC_PLAT" != 'tvos' ]]; then
                echo "plat must be: [ios|macos|tvos]"
                exit 1
            fi
        ;;
        c)
            XC_CMD="$OPTARG"
        ;;
        a)
            XC_ALL_ARCHS="$OPTARG"
        ;;
        l)
            LIBS="$OPTARG"
        ;;
        d)
            XC_DEBUG='debug'
        ;;
        t)
            XC_THREAD="$OPTARG"
        ;;
    esac
done

shift $((OPTIND-1))

if [[ -z "$XC_THREAD" ]];then
    XC_THREAD=$(sysctl -n machdep.cpu.thread_count)
    echo "support thread count:$XC_THREAD"
fi

if [[ -z "$XC_CMD" ]];then
    echo "cmd can't be nil. use -c specify cmd"
    exit 1
fi

if [[ -z "$LIBS" ]];then
    echo "libs can't be nil. use -l specify libs"
    exit 1
fi

export XC_THREAD
export XC_PLAT
export XC_CMD
export XC_DEBUG

if [[ "$LIBS" == "all" ]]; then
    list='compile-cfgs/list.txt'
    #use plat list
    if [[ -f "compile-cfgs/list_${XC_PLAT}.txt" ]]; then
        list="compile-cfgs/list_${XC_PLAT}.txt"
    fi
    LIBS=$(cat $list)
fi

export XC_VENDOR_LIBS="$LIBS"
export XC_ALL_ARCHS

source 'init-env.sh'
init_plat_env

echo '------------------------------------------'
echo "XC_PLAT         : [$XC_PLAT]"
echo "XC_CMD          : [$XC_CMD]"
echo "XC_VENDOR_LIBS  : [$XC_VENDOR_LIBS]"
echo "XC_ALL_ARCHS    : [$XC_ALL_ARCHS]"
echo "XC_DEBUG        : [$XC_DEBUG]"
echo "XC_FORCE_CROSS  : [$XC_FORCE_CROSS]"
echo "XC_THREAD       : [$XC_THREAD]"
echo '------------------------------------------'

START_STMP=$(date +%s)
# 循环编译所有的库
for lib in $LIBS
do
    echo "===[$XC_CMD $lib]===================="
    source compile-cfgs/"$lib"
    
    ./do-compile/any.sh
    if [[ $? -eq 0 ]];then
        echo "🎉  Congrats"
        echo "🚀  ${LIB_NAME} successfully $XC_CMD."
        echo
    fi
    echo "===================================="
done

END_STMP=$(date +%s)
take=$(( END_STMP - START_STMP ))
echo time elapsed ${take} s.

echo "===================================="