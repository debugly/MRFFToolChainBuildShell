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

# append "-DCMAKE_MACOSX_BUNDLE=NO" fix compile error:

# CMake Error at CMakeLists.txt:537 (install):
#   install TARGETS given no BUNDLE DESTINATION for MACOSX_BUNDLE executable
#   target "dwebp".

# call common cmake build shell
./cmake-compatible.sh "-DBUILD_SHARED_LIBS=OFF -DWEBP_LINK_STATIC=ON -DCMAKE_MACOSX_BUNDLE=NO -DWEBP_ENABLE_SIMD=ON -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_GIF2WEBP=OFF -DWEBP_BUILD_IMG2WEBP=OFF -DWEBP_BUILD_VWEBP=OFF -DWEBP_BUILD_WEBPINFO=OFF -DWEBP_BUILD_LIBWEBPMUX=OFF -DWEBP_BUILD_WEBPMUX=OFF -DWEBP_BUILD_EXTRAS=OFF -DWEBP_NEAR_LOSSLESS=OFF"

# clean cmake 
rm -rf ${MR_BUILD_PREFIX}/share