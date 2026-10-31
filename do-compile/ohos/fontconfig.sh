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

# fontconfig 2.18.3 meson.options declares nls as a feature option. Disable it
# explicitly: auto can discover the host gettext archive during cross builds.
./meson-compatible.sh "-Ddoc=disabled -Dtests=disabled -Dtools=disabled -Dnls=disabled"

python3 "$(dirname "$0")/../../tools/check-ohos-fontconfig.py" \
    --prefix "$MR_BUILD_PREFIX" --nm "$MR_NM"
