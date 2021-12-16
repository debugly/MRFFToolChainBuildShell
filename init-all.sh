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

PLAT=$1

./init-openssl.sh $PLAT

echo
./init-fdk-aac.sh $PLAT

echo
./init-lame.sh $PLAT

echo
./init-opus.sh $PLAT

echo
./init-x264.sh $PLAT

echo
./init-libass.sh $PLAT

echo
./init-libyuv.sh $PLAT

echo
./init-ffmpeg.sh $PLAT
