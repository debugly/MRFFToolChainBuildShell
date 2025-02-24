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

# call common cmake build shell
./cmake-compatible.sh

mkdir -p ${MR_BUILD_PREFIX}/lib/pkgconfig

echo "
prefix=${MR_BUILD_PREFIX}
includedir=\${prefix}/include
libdir=\${prefix}/lib

Name: yuv
Description: libyuv
Version: ${GIT_REPO_VERSION}
Libs: -L\${libdir} -lyuv
Cflags: -I\${includedir}" > ${MR_BUILD_PREFIX}/lib/pkgconfig/yuv.pc


