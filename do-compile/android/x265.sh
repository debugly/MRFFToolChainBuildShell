#!/usr/bin/env bash
#
# Copyright (C) 2021 Matt Reach<qianlongxu@gmail.com>
#
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

build="${MR_BUILD_SOURCE}/cmake_wksp"

rm -rf "$build"
mkdir -p "$build"
cd "$build"

CMAKE_OTHER_OPTS="-DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DENABLE_LIBNUMA=OFF"

if [[ "$_MR_ARCH" == "x86" || "$_MR_ARCH" == "x86_64" ]]; then
    CMAKE_OTHER_OPTS="$CMAKE_OTHER_OPTS -DENABLE_ASSEMBLY=OFF"
fi

if [[ -f "${MR_BUILD_SOURCE}/source/CMakeLists.txt" ]]; then
    echo "[*] Injecting CMAKE_CXX_FLAGS, target triple and sysroot into ARM_ARGS for x265"
    perl -pi -e 's/add_definitions\(\$\{ARM_ARGS\}\)/add_definitions(\${ARM_ARGS})\n    string(REPLACE " " ";" CMAKE_CXX_FLAGS_LIST "\${CMAKE_CXX_FLAGS}")\n    list(APPEND ARM_ARGS \${CMAKE_CXX_FLAGS_LIST})\n    if(CMAKE_CXX_COMPILER_TARGET)\n        list(APPEND ARM_ARGS "--target=\${CMAKE_CXX_COMPILER_TARGET}")\n    endif()\n    if(CMAKE_SYSROOT)\n        list(APPEND ARM_ARGS "--sysroot=\${CMAKE_SYSROOT}")\n    endif()/g' "${MR_BUILD_SOURCE}/source/CMakeLists.txt"
fi

cmake -S "${MR_BUILD_SOURCE}/source"                         \
    -DCMAKE_INSTALL_PREFIX=${MR_BUILD_PREFIX}       \
    -DANDROID_NDK=${MR_ANDROID_NDK_HOME}            \
    -DANDROID_ABI=${MR_ANDROID_ABI}                 \
    -DCMAKE_RANLIB=${MR_RANLIB}                     \
    -DCMAKE_AR=${MR_AR}                             \
    -DCMAKE_STRIP=${MR_STRIP}                       \
    -DCMAKE_CXX_COMPILER_RANLIB=${MR_RANLIB}        \
    -DANDROID_PLATFORM=android-${MR_ANDROID_API}    \
    -DANDROID_STL=c++_shared                        \
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${MR_BUILD_PREFIX}/libs/${MR_ANDROID_ABI}       \
    -DCMAKE_TOOLCHAIN_FILE=${MR_ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
    ${CMAKE_OTHER_OPTS}

echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

cmake_cmd="cmake --build ."

if [[ "$MR_DEBUG" == "debug" ]];then
    cmake_cmd="$cmake_cmd --config Debug"
else
    cmake_cmd="$cmake_cmd --config Release"
fi

eval "$cmake_cmd"

cmake --install . --strip

if [[ -f "$MR_BUILD_PREFIX/lib/pkgconfig/x265.pc" ]]; then
    echo "[*] Appending -lc++_shared to Libs.private in x265.pc"
    perl -pi -e 's/Libs.private: (.*)/Libs.private: $1 -lc++_shared/' "$MR_BUILD_PREFIX/lib/pkgconfig/x265.pc"
fi
