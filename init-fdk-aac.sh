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

# export GIT_UPSTREAM=https://github.com/mstorsjo/fdk-aac.git
export GIT_UPSTREAM=git@code.sohuno.com:ifox-mac/fdk-aac.git
export GIT_LOCAL_REPO=extra/fdk-aac
export GIT_COMMIT=v2.0.2
export DIR_NAME=fdk-aac

./tools/init-repo.sh $*