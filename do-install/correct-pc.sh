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

        my_sed_i "s|^prefix=.*|prefix=$base_dir|" "$pc"
        my_sed_i "s|^exec_prefix=[^$].*|exec_prefix=$bin_dir|" $pc
        my_sed_i "s|^libdir=[^$].*|libdir=$lib_dir|" "$pc"
        my_sed_i "s|^includedir=[^$].*include|includedir=$include_dir|" "$pc"
        my_sed_i "s|-L/[^ ]*lib|-L$lib_dir|" "$pc"
        my_sed_i "s|-I/[^ ]*include|-I$include_dir|" "$pc"
    done
    
    cd "$dir"
}

correct_pc_file "$1"