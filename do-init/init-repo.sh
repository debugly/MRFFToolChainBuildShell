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
env_assert "SKIP_PULL_BASE"
env_assert "SMART_APPLY"
echo_env "MR_LIB_CONFIG_PATH"
echo_env "PATCH_DIR"
echo "===check env end==="

GIT_LOCAL_REPO="${MR_WORKSPACE}/${GIT_LOCAL_REPO}"

function pull_common() {
    
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
        if [[ "$SKIP_PULL_BASE" == "1" ]]; then
            echo "⚠️ skip pull $REPO_DIR because you set SKIP_PULL_BASE env."
        else
            echo "== pull $REPO_DIR base =="
            git fetch --all --tags
        fi
    else
        if [[ "$SKIP_PULL_BASE" == "1" ]]; then
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

# 用于合并ffmpeg的patch
apply_patch_smart() {
    local patch_file=$1

    if [ -z "$patch_file" ]; then
        echo "Usage: apply_patch_smart <patch_file>"
        return 1
    fi

    # 尝试静默执行 git am
    if git am "$patch_file" > /dev/null 2>&1; then
        echo "Successfully applied $(basename "$patch_file")"
    else
        echo "git am failed. Falling back to [git apply --reject]..."

        # 终止失败的 am 进程
        git am --abort

        # 尝试使用 --reject 强制应用
        if git apply --reject "$patch_file"; then
            echo "----------------------------------------------------"
            echo "Patch partially applied with --reject."
            echo "Please check for .rej files and resolve them manually."
            echo "----------------------------------------------------"

            # 列出生成的 .rej 文件提醒用户
            find . -name "*.rej"
        else
            echo "Error: [git apply --reject] also failed. Please check the patch file."
            return 1
        fi
    fi
}

function apply_patches() {

    if [[ -z "$PATCH_DIR" ]]; then
        echo "$REPO_DIR hasn't any patch"
        return
    fi

    local patch_base_dir=$(dirname "$MR_LIB_CONFIG_PATH")
    local patch_dir="${patch_base_dir}/$PATCH_DIR"
    local patch_dirs=(
        "$patch_dir"
        "${patch_dir}-${MR_PLAT}"
        "${patch_dir}-pro"
    )

    for patch_dir in "${patch_dirs[@]}"; do
        if [[ ! -d "$patch_dir" ]]; then
            echo "patch dir not exist: $patch_dir, skip."
            continue
        fi

        echo
        echo "== Applying patches: $(basename "$patch_dir") → $(basename "$PWD") =="
        if [[ "$SMART_APPLY" == "1" ]]; then
            for patch_file in "$patch_dir"/*.patch; do
                if ! apply_patch_smart "$patch_file"; then
                    echo "Apply patch failed: $patch_file"
                    exit 1
                fi
            done
        else
            if ! git am --whitespace=fix --keep "$patch_dir"/*.patch; then
                echo 'Apply patches failed!'
                git am --skip
                exit 1
            fi
        fi
        echo
    done
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
