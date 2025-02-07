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

# disabling pkg-config-path
# https://gstreamer-devel.narkive.com/TeNagSKN/gst-devel-disabling-pkg-config-path
# export PKG_CONFIG_LIBDIR=${sysroot}/lib/pkgconfig

env_assert "MR_UNI_PROD_DIR"
env_assert "MR_UNI_SIM_PROD_DIR"

pkg_cfg_dir=

if [[ "$MR_IS_SIMULATOR" == 1 ]];then
    uni_dir="${MR_UNI_SIM_PROD_DIR}"
else
    uni_dir="${MR_UNI_PROD_DIR}"
fi

for dir in `[ -d ${uni_dir} ] && find "${uni_dir}" -type f -name "*.pc" | xargs dirname | uniq` ;
do
    if [[ $pkg_cfg_dir ]];then
        pkg_cfg_dir="${pkg_cfg_dir}:${dir}"
    else
        pkg_cfg_dir="${dir}"
    fi
done

export PKG_CONFIG_LIBDIR="$pkg_cfg_dir"

unset uni_dir