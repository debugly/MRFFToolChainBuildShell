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

compile ijkplayer using libs for iOS、macOS、tvOS、Android platform, such as ass、ffmpeg...

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
    -l                   Specify which libs need init (all|libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
    -s                   Specify workspace dir
    --help               Show help banner of init command
    --skip-pull-base     Skip pull base repo
    --skip-patches       Skip apply FFmpeg patches
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
    -l            Specify which libs need 'cmd' (all|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
    -s            Specify workspace dir
    -j            Force number of cores to be used
    --help        Show help banner of compile command
    --debug       Enable debug mode (disable by default)
    --skip-fmwk   Skip make xcframework(apple platform only)
EOF
}

function install_usage()
{
cat << EOF
usage: ./main.sh install [options]

Download and Install Pre-compile library to product dir

OPTIONS:
   -p            Specify platform (ios,macos,tvos), can't be nil
   -l            Specify which libs need 'cmd' (all|libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
   -s            Specify workspace dir
   -correct-pc  Specify a path for correct the pc file prefix recursion
   --help        Show intall help
   --fmwk        Install xcframework bundle instead of .a
EOF
}

function fix_prefix(){
    local fix_path="$1"
    local dir=${PWD}
    
    echo "fix pc files in folder: $fix_path"
    cd "$fix_path"
    
    for pc in `find . -type f -name "*.pc"` ;
    do
        echo "$pc"
        local pc_dir=$(DIRNAME=$(dirname "$pc"); cd "$DIRNAME"; pwd)
        local lib_dir=$(dirname "$pc_dir")
        local base_dir=$(dirname "$lib_dir")
        
        base_dir=$(cd "$base_dir";pwd)
        local escaped_base_dir=$(echo $base_dir | sed 's/\//\\\//g')
        local escaped_lib_dir=$(echo "${base_dir}/lib" | sed 's/\//\\\//g')
        local escaped_include_dir=$(echo "${base_dir}/include" | sed 's/\//\\\//g')
        
        sed -i "" "s/^prefix=.*/prefix=$escaped_base_dir/" "$pc"
        sed -i "" "s/^libdir=.*/libdir=$escaped_lib_dir/" "$pc"
        sed -i "" "s/^includedir=.*/includedir=$escaped_include_dir/" "$pc"
        
        # filte Libs using -L/ absolute path
        local str=
        for t in `cat "$pc" | grep "Libs: " | grep "\-L/"` ;
        do
            if [[ "$t" != -L/* ]];then
                if [[ $str ]];then
                    str="${str} $t"
                else
                    str="$t"
                fi
            fi
        done
        [[ ! -z $str ]] && sed -i "" "s/^Libs:.*/$str/" "$pc"
    done
    
    cd "$dir"
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
        echo "$name:${value}" >&2
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
        --skip-pull-base)
            export SKIP_PULL_BASE=1
        ;;
        --skip-ff-patches)
            export SKIP_FFMPEG_PATHCHES=1
        ;;
        --skip-fmwk)
            export MR_SKIP_MAKE_XCFRAMEWORK=1
        ;;
        -correct-pc)
            shift
            fix_prefix "$1"
            exit 0
        ;;
        **)
            echo "unkonwn option:$1"
        ;;
    esac
    shift
done

if [[ -z "$platform" ]];then
    help
    exit 1
fi

if [[ "$platform" != 'ios' && "$platform" != 'macos' && "$platform" != 'tvos' && "$platform" != 'android' ]]; then
    echo "platform must be: [ios|macos|tvos|android]"
    exit 1
fi

if [[ -z "$libs" ]];then
    echo "libs can't be nil, use -l specify libs"
    exit 1
fi

if [[ -n "$nproc" ]];then
    echo "override thread count:$nproc"
    export MR_HOST_NPROC=$nproc
fi

# -arch $MR_ARCH
cflags="-Wno-int-conversion -Wno-declaration-after-statement -Wno-unused-function"

if [[ "$MR_DEBUG" == "debug" ]];then
    export MR_OTHER_CFLAGS="-g -O0 -D_DEBUG $cflags"
else
    export MR_OTHER_CFLAGS="-O3 -DNDEBUG $cflags"
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

if [[ "$MR_VENDOR_LIBS" == "all" ]]; then
    cfg_dir=$(DIRNAME=$(dirname "${BASH_SOURCE[0]}"); cd "${DIRNAME}/../configs"; pwd)
    source "${cfg_dir}/default.sh"

    eval libs='$'"${MR_PLAT}_default_libs"
    export MR_VENDOR_LIBS="$libs"
fi

echo "MR_ACTION       : [$MR_ACTION]"
echo "MR_PLAT         : [$MR_PLAT]"
echo "MR_CMD          : [$MR_CMD]"
echo "MR_VENDOR_LIBS  : [$MR_VENDOR_LIBS]"
echo "MR_ACTIVE_ARCHS : [$MR_ACTIVE_ARCHS]"
echo "MR_HOST_NPROC   : [$MR_HOST_NPROC]"
echo "MR_DEBUG        : [$MR_DEBUG]"
echo "MR_OTHER_CFLAGS : [$MR_OTHER_CFLAGS]"
echo "SKIP_PULL_BASE  : [$SKIP_PULL_BASE]"
echo "SKIP_FFMPEG_PATHCHES : [$SKIP_FFMPEG_PATHCHES]"
echo "MR_SKIP_MAKE_XCFRAMEWORK" : [$MR_SKIP_MAKE_XCFRAMEWORK]

unset platform cmd arch libs workspace debug action cflags
