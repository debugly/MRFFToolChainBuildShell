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
# ./install-pre-any.sh all
# ./install-pre-any.sh ios 'libyuv openssl opus bluray dav1d'
# ./install-pre-any.sh macos 'openssl'
# ./install-pre-any.sh macos 'openssl ffmpeg'


#----------------------------------------------------------
# 当发布新版本库时，修改对应的 TAG 值
#----------------------------------------------------------
UNIBREAK_TAG='unibreak-5.1-240604135117'
OPUS_TAG=''
MAC_BLURAY_TAG=''
DAV1D_TAG=''
OPENSSL_TAG=''
DVDREAD_TAG=''
FREETYPE_TAG=''
FRIBIDI_TAG=''
HARFBUZZ_TAG=''
ASS_TAG=''
FFMPEG_TAG=''
#----------------------------------------------------------

set -e

LIBS="$1"

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

function usage() {
    echo "=== useage ===================="
    echo "Download pre-compiled xcframeworks from github:"
    echo " $0 [all|openssl|opus|bluray|dav1d|freetype|fribidi|harfbuzz|unibreak|ass|ffmpeg]"
    exit 1
}

if [[ "$LIBS" == "-h" || -z "$LIBS" ]]; then
    usage
fi

if [[ "$LIBS" == "all" ]]; then
    LIBS=$(ls init-cfgs)
fi

for lib in $LIBS
do
    TAG=
    echo "===[install pre-compile $lib]===================="
    
    case $lib in
        'ffmpeg')
            TAG=$FFMPEG_TAG
        ;;
        'libyuv')
            TAG=$LIBYUV_TAG
        ;;
        'openssl')
            TAG=$OPENSSL_TAG
        ;;
        'opus')
            TAG=$OPUS_TAG
        ;;
        'bluray')
            TAG=$MAC_BLURAY_TAG
        ;;
        'dav1d')
            TAG=$DAV1D_TAG
        ;;
        'dvdread')
            TAG=$DVDREAD_TAG
        ;;
        'freetype')
            TAG=$FREETYPE_TAG
        ;;
        'harfbuzz')
            TAG=$HARFBUZZ_TAG
        ;;
        'fribidi')
            TAG=$FRIBIDI_TAG
        ;;
        'unibreak')
            TAG=$UNIBREAK_TAG
        ;;
        'ass')
            TAG=$ASS_TAG
        ;;
        *)
            echo "wrong lib name:$lib"
            usage
        ;;
    esac
    
    if [[ -z "$TAG" ]]; then
        echo "== $lib tag is empty,just skip it."
    else
        echo "== install $lib -> $TAG"
        ./tools/install-pre-xcf.sh "$TAG"
    fi
    echo "===================================="
done