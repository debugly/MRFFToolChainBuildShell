#! /usr/bin/env bash
#
# Copyright (C) 2022 Matt Reach<qianlongxu@gmail.com>

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

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR" 

function correct_pc_file(){
    local fix_path="$1"
    local dir=${PWD}
    
    echo "fix pc files in folder: $fix_path"
    cd "$fix_path"
    for pc in `find . -type f -name "*.pc"` ;
    do
        local pkgconfig=$(cd $(dirname "$pc"); pwd)
        local lib_dir=$(cd $(dirname "$pkgconfig"); pwd)
        local base_dir=$(cd $(dirname "$lib_dir"); pwd)
        local include_dir="${base_dir}/include"
        local bin_dir="${base_dir}/bin"
        
        # fix absolute path which contains arch suffix bug，such as /path/to/opus-arch/lib
        #-L/Users/runner/work/MRFFToolChainBuildShell/MRFFToolChainBuildShell/build/product/macos/opus-arch/lib
        #->
        #-L/Users/runner/work/MRFFToolChainBuildShell/MRFFToolChainBuildShell/build/product/macos/universal/opus/lib
        # my_sed_i "s|${LIB_NAME}-arm64[^/]*/|universal/${LIB_NAME}/|g" "$pc"
        # 匹配逻辑：
        # 1. 匹配 [^/]*           -> 路径中最后一个斜杠后的字符（即 LIB_NAME）
        # 2. 匹配 -(arm64|x86)    -> 紧跟其后的架构标识
        # 3. 匹配 [^/]*           -> 架构后的剩余后缀（如 _simulator）
        # 4. 替换为 universal/\1  -> \1 就是第一对括号捕获到的 LIB_NAME

        my_sed_i "s|\([^/]*\)-arm64[^/]*|universal/\1|g" "$pc"
        my_sed_i "s|\([^/]*\)-x86[^/]*|universal/\1|g" "$pc"
        
        # 全局替换 prefix= 开头后面的内容
        old_base=$(sed -n 's/^prefix=//p' "$pc")
        my_sed_i "s|$old_base|$base_dir|g" "$pc"

        # 具有局限性，比如 includedir=/Users/matt/GitWorkspace/fsplayer/FFToolChain/build/product/ios/universal-simulator/bluray
        # my_sed_i "s|^prefix=.*|prefix=$base_dir|" "$pc"
        # my_sed_i "s|^exec_prefix=[^$].*|exec_prefix=$bin_dir|" $pc
        # my_sed_i "s|^libdir=[^$].*|libdir=$lib_dir|" "$pc"
        # my_sed_i "s|^includedir=[^$].*include|includedir=$include_dir|" "$pc"

        

        # Fix absolute paths to other internal dependencies
        # Pattern: -L/any/path/PRODUCT_NAME/PLATFORM/universal/LIB_NAME/lib
        # We want to replace the "/any/path/PRODUCT_NAME/PLATFORM" part with the local equivalent.
        # Since we know the local product root is the parent of 'universal', we can use that.
        
        local product_root=$(cd "$fix_path"; pwd)
        # escaped for sed
        local escaped_root=$(echo "$product_root" | sed 's/\//\\\//g')
        
        # 1. Fix -L/path/to/universal/LIB_NAME/lib -> -L/local/product/universal/LIB_NAME/lib
        my_sed_i "s|-L/[^ ]*/universal/\([^ /]*\)/lib|-L$escaped_root/universal/\1/lib|g" "$pc"
        # 2. Fix -I/path/to/universal/LIB_NAME/include -> -I/local/product/universal/LIB_NAME/include
        my_sed_i "s|-I/[^ ]*/universal/\([^ /]*\)/include|-I$escaped_root/universal/\1/include|g" "$pc"
    done
    
    cd "$dir"
}

correct_pc_file "$1"