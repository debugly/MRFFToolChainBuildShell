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

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

function check_lib()
{
    local lib=$1
    if pkg-config --exists "$lib"; then
        echo "[✅] $lib : $(pkg-config --modversion $lib)" #, $(pkg-config --cflags $lib)
    else
        echo "[❌] $lib not found!" >&2
        return 1
    fi
}

echo "--check denpendencies--------------------"
check_lib 'freetype2'
check_lib 'fribidi'
check_lib 'harfbuzz'
check_lib 'libunibreak'
check_lib 'fontconfig'
echo "----------------------"

./meson-compatible.sh "-Dtest=disabled -Dprofile=disabled -Dfontconfig=enabled -Dcoretext=disabled -Dasm=disabled -Dlibunibreak=enabled"


# A static archive alone does not verify that its dependencies can be linked.
# Cross-link a renderer without attempting to run the OHOS executable on macOS.
export PKG_CONFIG_LIBDIR="$MR_BUILD_PREFIX/lib/pkgconfig:$PKG_CONFIG_LIBDIR"
cat > "$MR_BUILD_SOURCE/ass-link-check.cpp" <<'CHECK'
#include <ass/ass.h>
int main(void)
{
    ASS_Library *library = ass_library_init();
    if (!library) return 1;
    ASS_Renderer *renderer = ass_renderer_init(library);
    if (renderer) ass_renderer_done(renderer);
    ass_library_done(library);
    return renderer ? 0 : 1;
}
CHECK
"$MR_TRIPLE_CXX" $MR_DEFAULT_CFLAGS $(pkg-config --cflags libass) \
    "$MR_BUILD_SOURCE/ass-link-check.cpp" \
    -o "$MR_BUILD_SOURCE/ass-link-check" $(pkg-config --libs --static libass)
echo "[✅] libass and its static dependencies link for $MR_ARCH"
