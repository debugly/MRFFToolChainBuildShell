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

# you can export GIT_FDK_UPSTREAM=git@xx:yy/libass.git use your mirror

if [[ "$GIT_LIBASS_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_LIBASS_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/libass/libass.git
fi
echo "$GIT_UPSTREAM"

export GIT_LOCAL_REPO=extra/libass
export GIT_COMMIT=0.15.2
export REPO_DIR=libass

./tools/init-repo.sh $*