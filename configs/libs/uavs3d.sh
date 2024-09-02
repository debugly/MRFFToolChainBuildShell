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
#
#

# LIB_DEPENDS_BIN using string because bash can't export array chttps://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script
# configure: error: Package requirements (openssl) were not met

export LIB_NAME='uavs3d'
export LIPO_LIBS="libuavs3d"
export LIB_DEPENDS_BIN="cmake"
export GIT_LOCAL_REPO=build/extra/uavs3d
export GIT_COMMIT=1fd0491
export REPO_DIR=uavs3d
export GIT_REPO_VERSION=1.2.1
export PRE_COMPILE_TAG=uavs3d-1.2.1-240902150946

# you can export GIT_UAVS3D_UPSTREAM=git@xx:yy/UAVS3D.git use your mirror
if [[ "$GIT_UAVS3D_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_UAVS3D_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/uavs3/uavs3d.git
fi