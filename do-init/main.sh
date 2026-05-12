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

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-pull-base)
                SKIP_PULL_BASE=1
            ;;
            --smart-apply)
                SMART_APPLY=1
                ;;
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

function do_init_a_lib()
{
    local lib_config="$1"    
    echo "===[init $lib_config]===================="
    [[ ! -f "$lib_config" ]] && (echo "❌$lib_config config not exist,init will stop.";exit 1;)
    source "$lib_config"
    ./init-repo.sh
    echo "========================="
}

function main() {

    export SKIP_PULL_BASE=${SKIP_PULL_BASE:-0}
    export SMART_APPLY=${SMART_APPLY:-0}

    for lib in $MR_VENDOR_LIBS
    do
        do_init_a_lib "$MR_SHELL_CONFIGS_DIR/libs/${lib}.sh"
    done

    if [[ -n "$LIB_CONFIG_PATH" ]];then
        echo 
        echo "init specific lib config : [$LIB_CONFIG_PATH]"
        do_init_a_lib "$LIB_CONFIG_PATH"
    fi
}

parse_args "$@"
main