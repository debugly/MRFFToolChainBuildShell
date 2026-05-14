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

function do_compile_a_lib() 
{
    local lib_config="$1"
    [[ ! -f "$lib_config" ]] && (echo "❌$lib_config config not exist, compile will stop."; exit 1;)

    echo "===[$MR_CMD $lib]===================="
    source "$lib_config"

    echo "LIB_NAME        : [$LIB_NAME]"
    echo "GIT_COMMIT      : [$GIT_COMMIT]"
    echo "LIPO_LIBS       : [$LIPO_LIBS]"
    echo "GIT_UPSTREAM    : [$GIT_UPSTREAM]"

    ./any.sh
    if [[ $? -eq 0 ]];then
        echo "🎉  Congrats"
        echo "🚀  ${LIB_NAME} ${GIT_COMMIT} successfully $MR_CMD."
        echo
    fi
    echo "===================================="
}

function compile_libs()
{
    # 循环编译所有的库
    for lib in $MR_VENDOR_LIBS
    do
        do_compile_a_lib "$MR_SHELL_CONFIGS_DIR/libs/${lib}.sh"
    done

    if [[ -n "$LIB_CONFIG_PATH" ]];then
        echo 
        echo "install specific lib config : [$LIB_CONFIG_PATH]"
        do_compile_a_lib "$LIB_CONFIG_PATH"
    fi
}

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -lib-config)
                shift
                LIB_CONFIG_PATH="$1"
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
echo "LIB_CONFIG_PATH:$LIB_CONFIG_PATH"
compile_libs