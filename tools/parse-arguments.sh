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

set -e

function main_usage()
{
cat << EOF
usage: ./main.sh [options]

compile fsplayer using libs for iOS、macOS、tvOS、Android platform, such as ass、ffmpeg...

Commands:
   +help         Show help banner of specified command
   +init         Clone vendor library git repository,Checkout specify commit,Apply patches
   +compile      Compile vendor library,more parameter see ./main.sh compile -h
   +install      Download and Install Pre-compile library to product dir
EOF
}

function init_usage()
{
cat << EOF
usage: ./main.sh init [options]

Clone vendor library git repository,Checkout specify commit,Apply patches

OPTIONS:
    -p                   Specify platform (ios,macos,tvos,android), can't be nil
    -a                   Specify archs (x86_64,arm64,x86_64_simulator,arm64_simulator,all) all="x86_64,arm64,x86_64_simulator,arm64_simulator"
    -l                   Specify which libs need init (libyuv|openssl|openssl3|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ijkffmpeg|fftutorial|ffmpeg4|ffmpeg5|ffmpeg6|ffmpeg7), can't be nil
    -s                   Specify workspace dir
    --help               Show help banner of init command
    --skip-pull-base     Skip pull base repo
    --smart-apply        Apply patches with git apply --reject instead of git am
    -lib-config          Read library config from specified path,eg: -lib-path ~/matt/lib/ffmpeg.sh
EOF
}

function compile_usage()
{
cat << EOF
usage: ./main.sh compile [options]

Compile libs, such as ass、ffmpeg...

OPTIONS:
    -c            Specify sub command (build,clean,rebuild) rebuild=clean+build, default is build
    -a            Specify archs (x86_64,arm64,x86_64_simulator,arm64_simulator,all) all="x86_64,arm64,x86_64_simulator,arm64_simulator"
    -l            Specify which libs need 'cmd' (openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
    -s            Specify workspace dir
    -j            Force number of cores to be used
    --help        Show help banner of compile command
    --debug       Enable debug mode (disable by default)
    --fmwk        Make xcframework(apple platform only)
EOF
}

function install_usage()
{
cat << EOF
usage: ./main.sh install [options]

Download and Install Pre-compile library to product dir

OPTIONS:
   -p            Specify platform (ios,macos,tvos), can't be nil
   -l            Specify which libs need 'cmd' (libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
   -s            Specify workspace dir
   --help        Show intall help
   --fmwk        Install xcframework bundle instead of .a
   -lib-config   Read library config from specified path,eg: -lib-path ~/matt/lib/ffmpeg.sh
   -correct-pc   Specify a path for correct the pc file prefix recursion
EOF
}

function parse_path()
{
    local p="$1"
    if [[ $p == /* ]]; then
        echo $(cd "$p"; pwd)
    else
        local dir="$MR_SHELL_ROOT_DIR/$p"
        echo $(mkdir -p "$dir";cd "$dir";pwd)
    fi
}

function env_assert()
{
    name="$1"
    value=$(eval echo "\$$name")
    if [[ "x$value" == "x" ]]; then
        echo "$name is nil,eg: export $name=xx" >&2
        exit 1
    else
        echo "$name : [${value}]" >&2
    fi
}

export -f env_assert

function help()
{
    eval ${MR_ACTION}_usage
}

action=
cmd=
platform=
arch=
libs=
workspace=
debug=
has_lib_config=
MR_UNKNOWN_OPTIONS=()

case $1 in
    init | install)
        action=$1
        shift 1
    ;;
    compile)
        action=$1
        shift 1
        cmd=build
    ;;
    *)
        main_usage
        exit 0
    ;;
esac

export MR_ACTION=$action

while [[ $# -gt 0 ]]; do
    case $1 in
        -p)
            shift
            platform="$1"
        ;;
        -c)
            shift
            cmd="$1"
        ;;
        -a)
            shift
            arch="$1"
        ;;
        -l)
            shift
            libs="$1"
        ;;
        -s)
            shift
            workspace=$(parse_path "$1")
        ;;
        -j)
            shift
            nproc="$1"
        ;;
        --help)
            help
            exit 0
        ;;
        --debug)
            export MR_DEBUG='debug'
        ;;
        --fmwk)
            export MR_MAKE_XCFRAMEWORK=1
        ;;
        -lib-config)
            MR_UNKNOWN_OPTIONS+=("$1")
            has_lib_config=1
        ;;
        -correct-pc)
            MR_UNKNOWN_OPTIONS+=("$1")
            has_correct_pc=1
        ;;
        *)
            MR_UNKNOWN_OPTIONS+=("$1")
        ;;
    esac
    shift
done

if [[ -z "$platform" ]];then
    echo "platform can't empty"
    help
    exit 1
fi

if [[ "$platform" != 'ios' && "$platform" != 'macos' && "$platform" != 'tvos' && "$platform" != 'android' ]]; then
    echo "platform must be: [ios|macos|tvos|android]"
    exit 1
fi

if [[ -z "$libs" && "$has_lib_config" != "1" && "$has_correct_pc" != "1" ]];then
    echo "libs can't be nil, use -l specify libs"
    exit 1
fi

if [[ -n "$nproc" ]];then
    echo "override thread count:$nproc"
    export MR_HOST_NPROC=$nproc
fi

cflags="-Wno-incompatible-function-pointer-types -Wno-int-conversion -Wno-declaration-after-statement -Wno-unused-function"

if [[ "$MR_DEBUG" == "debug" ]];then
    export MR_INIT_CFLAGS="-g -O0 -D_DEBUG $cflags"
else
    export MR_INIT_CFLAGS="-O3 -DNDEBUG $cflags"
fi

export MR_PLAT="$platform"
export MR_CMD="$cmd"
export MR_VENDOR_LIBS="$libs"
export MR_ACTIVE_ARCHS="$arch"

if [[ "$workspace" ]];then
    export MR_WORKSPACE="$workspace"
    echo "MR_WORKSPACE:$MR_WORKSPACE"
fi

case $MR_PLAT in
    ios | macos | tvos)
        source $MR_SHELL_TOOLS_DIR/export-apple-host-env.sh
    ;;
    android)
        source $MR_SHELL_TOOLS_DIR/export-android-host-env.sh
    ;;
    *)
        echo "wrong platform $MR_PLAT"
        exit 1
    ;;
esac

if [[ -z "$MR_ACTIVE_ARCHS" ]];then
    export MR_ACTIVE_ARCHS=$MR_DEFAULT_ARCHS
else
    for arch in $MR_ACTIVE_ARCHS
    do
        validate=0
        for arch2 in $MR_DEFAULT_ARCHS
        do
            if [[ $arch == $arch2 ]];then
                validate=1
            fi
        done
        if [[ $validate -eq 0 ]];then
            echo "the $arch is not validate on ${MR_PLAT},you can use [$MR_DEFAULT_ARCHS]"
            exit 1
        fi
    done
fi


echo "MR_ACTION       : [$MR_ACTION]"
echo "MR_PLAT         : [$MR_PLAT]"
echo "MR_CMD          : [$MR_CMD]"
echo "MR_VENDOR_LIBS  : [$MR_VENDOR_LIBS]"
echo "MR_ACTIVE_ARCHS : [$MR_ACTIVE_ARCHS]"
echo "MR_HOST_NPROC   : [$MR_HOST_NPROC]"
echo "MR_DEBUG        : [$MR_DEBUG]"
echo "MR_INIT_CFLAGS  : [$MR_INIT_CFLAGS]"
echo "MR_MAKE_XCFRAMEWORK" : [$MR_MAKE_XCFRAMEWORK]
[[ ${#MR_UNKNOWN_OPTIONS[@]} -gt 0 ]] && echo "MR_UNKNOWN_OPTIONS : [${MR_UNKNOWN_OPTIONS[*]}]"

unset platform cmd arch libs workspace debug action cflags
