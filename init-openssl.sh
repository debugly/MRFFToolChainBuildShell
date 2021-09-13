#! /usr/bin/env bash
#
# Copyright (C) 2013-2015 Bilibili
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

# IJK_OPENSSL_UPSTREAM=https://github.com/openssl/openssl.git
# IJK_OPENSSL_FORK=https://github.com/Bilibili/openssl.git
# IJK_OPENSSL_COMMIT=OpenSSL_1_0_2q
# IJK_OPENSSL_LOCAL_REPO=extra/openssl

IJK_OPENSSL_UPSTREAM=git@code.sohuno.com:ifox-mac/openssl.git
IJK_OPENSSL_FORK=git@code.sohuno.com:ifox-mac/openssl.git
IJK_OPENSSL_COMMIT=OpenSSL_1_1_1l
IJK_OPENSSL_LOCAL_REPO=extra/openssl

set -e
TOOLS=tools

FF_iOS_ARCHS="x86_64 arm64"
FF_macOS_ARCHS="x86_64 arm64"


function pull_base()
{
    echo "== pull openssl base =="
    sh $TOOLS/pull-repo-base.sh $IJK_OPENSSL_UPSTREAM $IJK_OPENSSL_LOCAL_REPO
}

function pull_fork()
{
    local dir="$1/openssl-$2"
    echo "== pull openssl fork to $dir =="

    sh $TOOLS/pull-repo-ref.sh $IJK_OPENSSL_FORK $dir ${IJK_OPENSSL_LOCAL_REPO}
    cd $dir
    git checkout ${IJK_OPENSSL_COMMIT} -B mropenssl
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
