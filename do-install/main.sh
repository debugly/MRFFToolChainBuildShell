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
usage: ./main.sh install [options]

Download and Install Pre-compile library to product dir

OPTIONS:
   -p            Specify platform (ios,macos,tvos), can't be nil
   -l            Specify which libs need 'cmd' (all|libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
   -s            Specify workspace dir
   --help        Show intall help
   --fmwk        Install xcframework bundle instead of .a
   --correct-pc  Specify a path for correct the pc file prefix recursion
EOF
}

function fix_prefix(){
    local fix_path="$1"
    local dir=${PWD}
    
    echo "fix pc files prefix: $fix_path"
    cd "$fix_path"
    
    for pc in `find . -type f -name "*.pc"` ;
    do
        echo "$pc"
        local pc_dir=$(dirname "$pc")
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
    
    if command -v tree >/dev/null 2>&1; then
        tree -L 2 ./
    fi
    cd "$dir"
}

if [[ -z "$1" ]];then
    usage
    exit 1
fi

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
            exit 0
        ;;
        --fmwk)
            FORCE_XCFRAMEWORK=1
        ;;
        --correct-pc)
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

if [[ -z "$LIBS" ]];then
    echo "libs can't be nil, use -l specify libs"
    exit 1
fi

if [[ -z "$XC_PLAT" ]];then
    echo "platform can't be nil, use -p specify platform"
    exit 1
fi

export XC_PLAT
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
echo '------------------------------------------'

# 循环编译所有的库
for lib in $XC_VENDOR_LIBS
do
    [[ ! -f "../configs/libs/${lib}.sh" ]] && (echo "❌$lib config not exist,install will stop.";exit 1;)
    
    echo "===[install $lib]===================="
    source "../configs/libs/${lib}.sh"
    if [[ $FORCE_XCFRAMEWORK ]];then
        ./install-pre-xcf.sh
    else
        ./install-pre-lib.sh
    fi
    echo "===================================="
done

if [[ ! "$FORCE_XCFRAMEWORK" ]];then
    fix_prefix "$XC_WORKSPACE/product/$XC_PLAT"
fi

