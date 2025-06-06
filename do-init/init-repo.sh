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
# if you want skip pull base form net, you can export SKIP_PULL_BASE=1

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

echo "=== [$0] check env begin==="
env_assert "REPO_DIR"
env_assert "GIT_COMMIT"
env_assert "GIT_LOCAL_REPO"
env_assert "GIT_UPSTREAM"
env_assert "MR_WORKSPACE"
echo "===check env end==="

GIT_LOCAL_REPO="${MR_WORKSPACE}/${GIT_LOCAL_REPO}"

function pull_common() {
    echo "== pull $REPO_DIR base =="
    if [[ -d "$GIT_LOCAL_REPO" ]]; then
        cd "$GIT_LOCAL_REPO"
        [[ -d .git/rebase-apply ]] && git am --skip
        git reset --hard
        
        local origin=$(git remote get-url origin)
        if [[ "$origin" != "$GIT_UPSTREAM" ]]; then
            git remote remove origin
            git remote add origin "$GIT_UPSTREAM"
            echo "force update origin to: $GIT_UPSTREAM"
        fi
        if [[ "$SKIP_PULL_BASE" ]]; then
            echo "⚠️ skip pull $REPO_DIR because you set SKIP_PULL_BASE env."
        else
            git fetch --all --tags
        fi
    else
        if [[ "$SKIP_PULL_BASE" ]]; then
            echo "== local repo $REPO_DIR not exist,must clone by net firstly. =="
            echo "try:unset SKIP_PULL_BASE"
            exit -1
        else
            git clone $GIT_UPSTREAM $GIT_LOCAL_REPO
            cd "$GIT_LOCAL_REPO"
        fi
    fi
    
    # fix fatal: 'stable' is not a commit and a branch 'localBranch' cannot be created from it
    git checkout -B localBranch ${GIT_COMMIT}
    cd - >/dev/null
}

function apply_patches() {
    if [[ "$SKIP_FFMPEG_PATHCHES" && $LIB_NAME == ffmpeg* ]]; then
        echo "⚠️ skip apply $REPO_DIR patches,because you set SKIP_FFMPEG_PATHCHES env."
        return
    fi
    
    if [[ -z "$PATCH_DIR" ]]; then
        echo "$REPO_DIR hasn't any patch"
        return
    fi

    local plat="$MR_PLAT"
    local patch_dir="${THIS_DIR}/../patches/$PATCH_DIR"
    
    if [[ -d "${patch_dir}_${plat}" ]]; then
        patch_dir="${patch_dir}_${plat}"
    fi
    
    if [[ -d "$patch_dir" ]]; then
        echo
        echo "== Applying patches: $(basename $patch_dir) → $(basename $PWD) =="
        git am --whitespace=fix --keep $patch_dir/*.patch
        if [[ $? -ne 0 ]]; then
            echo 'Apply patches failed!'
            git am --skip
            exit 1
        fi
        echo
    fi
}

function make_arch_repo() {
    local dest_repo="${MR_SRC_ROOT}/$REPO_DIR-$1"
    ./copy-local-repo.sh $GIT_LOCAL_REPO $dest_repo
    cd $dest_repo
    if [[ "$GIT_WITH_SUBMODULE" ]]; then
        git submodule update --init --depth=1
    fi
    echo "last commit:"$(git log -1 --pretty=format:"[%h] %s:%ce %cd")
    apply_patches
    if ! git describe --tags >/dev/null 2>&1; then
        git tag "${GIT_REPO_VERSION}"
    fi
    tag=$(git describe --tags 2>/dev/null)
    echo "current tag:$tag"
    cd - >/dev/null
}

function usage() {
    echo "usage:"
    echo "$0 ios|macos|tvos|all [arm64|x86_64]"
}

function main() {
    case "$MR_PLAT" in
        ios | macos | tvos | android)
            pull_common
            for arch in $MR_ACTIVE_ARCHS; do
                make_arch_repo $arch
            done
        ;;
        *)
            usage
            exit 1
        ;;
    esac
}

main
