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
export MR_SHELL_ROOT_DIR="$THIS_DIR"
export MR_SHELL_TOOLS_DIR="${THIS_DIR}/tools"

function elapsed()
{
    local END_STMP=$(date +%s)
    local take=$(( END_STMP - START_STMP ))
    echo "===================================="
    echo time elapsed ${take} s.
}

START_STMP=$(date +%s)

echo '---1.parse arguments---------------------------------------'
source $MR_SHELL_TOOLS_DIR/parse-arguments.sh
echo '--------------------'
echo
echo '---2.prepare build workspace-------------------------------'
source $MR_SHELL_TOOLS_DIR/prepare-build-workspace.sh
echo '--------------------'
echo

echo "---3.do $action-------------------------------"
case $MR_PLAT in
    ios | macos | tvos)
        if [[ $action == "init" ]];then
            ./do-init/main.sh "$@"
        else
            ./do-compile/apple/main.sh "$@"
        fi 
    ;;
    android)
        if [[ $action == "init" ]];then
            ./do-init/main.sh "$@"
        else
            ./do-compile/android/main.sh "$@"
        fi
    ;;
esac
echo "---3.$action end-------------------------------"
echo

elapsed