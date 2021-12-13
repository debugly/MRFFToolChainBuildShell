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
# brew install nasm
# If you really want to compile without asm, configure with --disable-asm.

echo "======================"
echo 'check dependency:'
libs="nasm fdk-aac lame x264 libvpx xvid"

for lib in $libs
do
    brew list $lib > /dev/null
    if [[ 0 -ne $? ]];then
        echo "install $lib using brew."
        brew install $lib
    else
        echo "[*] $lib is ok."
    fi
done

echo "======================"

# 
CFLAGS=$(pkg-config --libs --cflags fdk-aac x264 vpx)
LDFLAGS=$(pkg-config --libs fdk-aac x264 vpx)

echo "$CFLAGS" 
echo "$LDFLAGS" 

export GLOBAL_C_FLAGS="$CFLAGS"
export GLOBAL_LIB_FLAGS="$LDFLAGS"