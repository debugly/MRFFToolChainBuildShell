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
usage: ./main.sh compile [options]

Compile libs for iOS and macOS and tvOS，such as libass、ffmpeg...

OPTIONS:
   -h            Show help banner of compile command
   -p            Specify platform (ios,macos,tvos), can't be nil
   -c            Specify sub command (build,clean,rebuild,lipo) rebuild=clean+build, can't be nil
   -a            Specify archs (x86_64,arm64,x86_64_simulator,arm64_simulator,all) all="x86_64,arm64,x86_64_simulator,arm64_simulator"
   -l            Specify which libs need 'cmd' (all|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
   -d            Enable debug mode (disable by default)
   -t            Force number of cores to be used
   -k            Skip make xcframework
EOF
}

if [[ -z "$1" ]];then
    usage
    exit 1
fi

while getopts "hp:c:a:l:dt:k" opt
do
    #echo "opt:$opt,OPTIND:[$OPTIND],OPTARG:[$OPTARG]"
    case $opt in
        h)
            usage
            exit 1
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
        k)
            XC_SKIP_MAKE_XCFRAMEWORK=1
        ;;
    esac
done

shift $((OPTIND-1))

if [[ -z "$XC_CMD" ]];then
    echo "cmd can't be nil, use -c specify cmd"
    exit 1
fi

if [[ -z "$LIBS" ]];then
    echo "libs can't be nil, use -l specify libs"
    exit 1
fi

if [[ -z "$XC_PLAT" ]];then
    echo "platform can't be nil, use -p specify platform"
    exit 1
fi

if [[ -z "$XC_THREAD" ]];then
    XC_THREAD=$(sysctl -n machdep.cpu.thread_count)
    echo "use default thread count:$XC_THREAD"
fi

export XC_THREAD
export XC_PLAT
export XC_CMD
export XC_DEBUG
export XC_VENDOR_LIBS="$LIBS"
export XC_ALL_ARCHS
export XC_SKIP_MAKE_XCFRAMEWORK

source '../tools/export-plat-env.sh'
init_plat_env

echo '------------------------------------------'
echo "XC_PLAT         : [$XC_PLAT]"
echo "XC_CMD          : [$XC_CMD]"
echo "XC_VENDOR_LIBS  : [$XC_VENDOR_LIBS]"
echo "XC_ALL_ARCHS    : [$XC_ALL_ARCHS]"
echo "XC_DEBUG        : [$XC_DEBUG]"
echo "XC_FORCE_CROSS  : [$XC_FORCE_CROSS]"
echo "XC_THREAD       : [$XC_THREAD]"
echo "XC_SKIP_MAKE_XCFRAMEWORK" : [$XC_SKIP_MAKE_XCFRAMEWORK]
echo '------------------------------------------'

# 循环编译所有的库
for lib in $XC_VENDOR_LIBS
do
    [[ ! -f "../configs/libs/${lib}.sh" ]] && (echo "❌$lib config not exist,compile will stop.";exit 1;)

    echo "===[$XC_CMD $lib]===================="
    source "../configs/libs/${lib}.sh"
    
    ./any.sh
    if [[ $? -eq 0 ]];then
        echo "🎉  Congrats"
        echo "🚀  ${LIB_NAME} successfully $XC_CMD."
        echo
    fi
    echo "===================================="
done