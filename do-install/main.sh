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
usage: ./main.sh install [options]

Download and Install Pre-compile library to product dir

OPTIONS:
   -h            Show intall help
   -p            Specify platform (ios,macos,tvos), can't be nil
   -l            Specify which libs need 'cmd' (all|libyuv|openssl|opus|bluray|dav1d|dvdread|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg), can't be nil
   -f            Install xcframework bundle instead of .a
EOF
}

function fix_prefix(){
    local plat=$XC_PLAT
    local dir=${PWD}
    
    echo "fix $plat platform pc files prefix"
    
    cd "../build/product/$plat"
    
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
        
        if [[ "$plat" == 'all' ]];then
            tree -L 3 ./
        else
            tree -L 2 ./
        fi
        
    fi
    cd "$dir"
}

if [[ -z "$1" ]];then
    usage
    exit 1
fi

while getopts "hp:l:f" opt
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
        l)
            LIBS="$OPTARG"
        ;;
        f)
            FORCE_XCFRAMEWORK=1
        ;;
    esac
done

shift $((OPTIND-1))

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

fix_prefix


