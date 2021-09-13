#! /usr/bin/env bash
#
# Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
#
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

# IJK_FFMPEG_UPSTREAM=git://git.videolan.org/ffmpeg.git
# IJK_FFMPEG_UPSTREAM=https://github.com/Bilibili/FFmpeg.git
# IJK_FFMPEG_FORK=https://github.com/Bilibili/FFmpeg.git
# IJK_FFMPEG_COMMIT=ff4.0--ijk0.8.8--20201130--001

IJK_FFMPEG_UPSTREAM=git@code.sohuno.com:ifox-mac/FFmpeg.git
IJK_FFMPEG_FORK=git@code.sohuno.com:ifox-mac/FFmpeg.git
IJK_FFMPEG_LOCAL_REPO=extra/ffmpeg
IJK_FFMPEG_COMMIT=origin/release/4.4
IJK_GASP_UPSTREAM=https://github.com/Bilibili/gas-preprocessor.git

# gas-preprocessor backup
# https://github.com/Bilibili/gas-preprocessor.git

if [ "$IJK_FFMPEG_REPO_URL" != "" ]; then
    IJK_FFMPEG_UPSTREAM=$IJK_FFMPEG_REPO_URL
    IJK_FFMPEG_FORK=$IJK_FFMPEG_REPO_URL
fi

if [ "$IJK_GASP_REPO_URL" != "" ]; then
    IJK_GASP_UPSTREAM=$IJK_GASP_REPO_URL
fi

set -e
TOOLS=tools

FF_iOS_ARCHS="x86_64 arm64"
FF_macOS_ARCHS="x86_64 arm64"

function echo_ffmpeg_version() {
    echo $IJK_FFMPEG_COMMIT
}

function pull_common() {
    git --version
    # echo "== pull gas-preprocessor base =="
    # sh $TOOLS/pull-repo-base.sh $IJK_GASP_UPSTREAM extra/gas-preprocessor

    echo "== pull ffmpeg base =="
    sh $TOOLS/pull-repo-base.sh $IJK_FFMPEG_UPSTREAM $IJK_FFMPEG_LOCAL_REPO
}

function pull_fork() {
    local dir="$1/ffmpeg-$2"
    echo "== pull ffmpeg fork to $dir =="
    
    sh $TOOLS/pull-repo-ref.sh $IJK_FFMPEG_FORK $dir ${IJK_FFMPEG_LOCAL_REPO}
    cd $dir
    git checkout ${IJK_FFMPEG_COMMIT} -B mrffmpeg
    cd - > /dev/null
}

function usage() {
    echo "$0 ios|macos|all [arm64|x86_64]"
}

function main() {
    case "$1" in
        iOS|ios)
            found=0
            for arch in $FF_iOS_ARCHS
            do
                if [[ "$2" == "$arch" || "x$2" == "x" ]];then
                    found=1
                    pull_fork 'ios' $arch
                fi
            done

            if [[ found -eq 0 ]];then
                echo "unknown arch:$2 for $1"
            fi
        ;;

        macOS|macos)
            
            found=0
            for arch in $FF_macOS_ARCHS
            do
                if [[ "$2" == "$arch" || "x$2" == "x" ]];then
                    found=1
                    pull_fork 'mac' $arch
                fi
            done

            if [[ found -eq 0 ]];then
                echo "unknown arch:$2 for $1"
            fi
        ;;

        all)

            for arch in $FF_iOS_ARCHS
            do
                pull_fork 'ios' $arch
            done

            for arch in $FF_macOS_ARCHS
            do
                pull_fork 'mac' $arch
            done
        ;;

        *)
            usage
            exit 1
        ;;
    esac
}

main $*