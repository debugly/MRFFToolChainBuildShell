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

TARGET="$1"

set -e
TOOLS=tools

function pull_base()
{
    echo "== pull openssl base =="
    sh $TOOLS/pull-repo-base.sh $IJK_OPENSSL_UPSTREAM $IJK_OPENSSL_LOCAL_REPO
}

function pull_fork()
{
    echo "== pull openssl fork $2 $1 =="
    dir="$2/openssl-$1"
    sh $TOOLS/pull-repo-ref.sh $IJK_OPENSSL_FORK $dir ${IJK_OPENSSL_LOCAL_REPO}
    cd $dir
    git checkout ${IJK_OPENSSL_COMMIT} -B mropenssl
    cd -
}

function main()
{
    if [ "$TARGET" = 'ios' ];then
        pull_base
        pull_fork "armv7" "$TARGET"
        pull_fork "armv7s" "$TARGET"
        pull_fork "arm64" "$TARGET"
        pull_fork "i386" "$TARGET"
        pull_fork "x86_64" "$TARGET"
    elif [ "$TARGET" = 'mac' ];then
        pull_base
        pull_fork "x86_64" "$TARGET"
        pull_fork "arm64" "$TARGET"
    else
        echo "Usage:"
        echo "  ./init-openssl.sh ios"
        echo "  ./init-openssl.sh mac"
        exit 1
    fi
}

main
