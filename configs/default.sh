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

# when '-l all' will use blew default config:
apple_default_libs="openssl opus dav1d dvdread freetype fribidi harfbuzz unibreak ass ffmpeg smb2 bluray"

android_default_libs="openssl opus dav1d dvdread xml2 freetype fribidi harfbuzz unibreak fontconfig ass ffmpeg smb2 bluray"

export ios_default_libs="$apple_default_libs"
export macos_default_libs="$apple_default_libs"
export tvos_default_libs="$apple_default_libs"
export android_default_libs="$android_default_libs"
