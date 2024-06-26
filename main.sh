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
usage: ./main.sh [options]

compile ijkplayer using libs for iOS and macOS and tvOS，such as libass、ffmpeg...

Commands:
   +help         Show help banner of specified command
   +init         Clone vendor library git repository,Checkout specify commit,Apply patches
   +compile      Compile vendor library,more parameter see ./main.sh compile -h
   +install      Download and Install Pre-compile library to product dir
EOF
}

function elapsed()
{
    local END_STMP=$(date +%s)
    local take=$(( END_STMP - START_STMP ))
    echo time elapsed ${take} s.
    echo "===================================="
}

START_STMP=$(date +%s)

case $1 in
    init)
        shift 1
        ./do-init/main.sh "$@"
        elapsed
    ;;
    install)
        shift 1
        ./do-install/main.sh "$@"
        elapsed
    ;;
    compile)
        shift 1
        ./do-compile/main.sh "$@"
        elapsed
    ;;
    *)
        usage
    ;;
esac
