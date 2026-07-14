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

function parse_lib_config() {
    local lib_config="$1"
    local config_file_name=$(basename "$lib_config")
    local config_name=${config_file_name%.sh}
    
    local t=$(echo "PRE_COMPILE_TAG_$MR_PLAT" | tr '[:lower:]' '[:upper:]')
    local vt=$(eval echo "\$$t")
    
    if test -z $vt ;then
        echo "$t can't be nil"
        exit
    fi
    
    # opus-1.3.1-231124151836
    # yuv-stable-eb6e7bb-250225223408
    export TAG=$vt
    
    local prefix="${config_name}-"
    local suffix=$(echo $TAG | awk -F - '{printf "-%s", $NF}')
    # 去掉前缀
    local temp=${TAG#$prefix}
    # 去掉后缀
    export VER=${temp%$suffix}
    # 跟onestep.sh保持一致，库名字是配置文件名
    export LIB_NAME="$config_name"
}

function do_install_a_lib()
{
    local lib_config="$1"
    lib_config=$(make_absolute_path "$lib_config")
    [[ ! -f "$lib_config" ]] && (echo "❌$lib_config config not exist,install will stop."; exit 1;)
        
    echo "===[install $lib_config]===================="
    source "$lib_config"
    parse_lib_config "$lib_config"
    if [[ $FORCE_XCFRAMEWORK ]];then
        ./install-pre-xcf.sh
    else
        ./install-pre-lib.sh
    fi
    echo "===================================="
}

function install_libs()
{
    # 循环安装所有的库
    for lib in $MR_VENDOR_LIBS
    do
        do_install_a_lib "configs/libs/${lib}.sh"
    done
    
    if [[ -n "$LIB_CONFIG_PATH" ]];then
        echo 
        echo "install specific lib config : [$LIB_CONFIG_PATH]"
        do_install_a_lib "$LIB_CONFIG_PATH"
    fi
}

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -lib-config)
                shift
                LIB_CONFIG_PATH="$1"
            ;;
            -correct-pc)
                shift
                CORRECT_PC="$1"
            ;;
            *)
                echo "unknown option: $1"
                sleep 2
                ;;
        esac
        shift
    done
}

parse_args "$@"

if [[ -n "$CORRECT_PC" ]];then
    echo "correct pc file : [$CORRECT_PC]"
    ./correct-pc.sh "$CORRECT_PC"
else
    install_libs
fi
