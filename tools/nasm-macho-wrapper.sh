#! /usr/bin/env bash
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
# ---------------------------------------------------------------------------
# nasm wrapper: 为 Apple (Mach-O) 汇编对象注入 LC_BUILD_VERSION
#
# 背景:
#   Xcode 15+ 的新链接器要求每个 Mach-O 对象携带 LC_BUILD_VERSION load command。
#   老版本 nasm (<2.16) 的 macho32/macho64 输出不写该 command, 导致链接时对每个
#   汇编对象报: "No platform load command found in '...', assuming: macOS"。
#   nasm >= 2.16 可用 `build_version <platform>, <maj>, <min>` 指令发射该 command。
#
# 行为:
#   - 仅当输出格式为 macho32/macho64 时, 从构建环境推导平台与最低系统版本,
#     通过 `--before "build_version ..."` 注入; 其他格式 (elf 等) 原样透传。
#   - 若真实 nasm 不支持 build_version (旧版本), 打印一次警告并透传, 不破坏构建。
#   - 通过 $MR_REAL_NASM 定位真实 nasm, 杜绝递归调用自身。
# ---------------------------------------------------------------------------

# 1. 定位真实 nasm。优先使用构建环境导出的 MR_REAL_NASM。
real_nasm="$MR_REAL_NASM"
if [[ -z "$real_nasm" || ! -x "$real_nasm" ]]; then
    # 回退: 在 PATH 中排除本 wrapper 所在目录后寻找 nasm。
    self_dir=$(cd "$(dirname "$0")" && pwd)
    saved_ifs="$IFS"; IFS=':'
    for d in $PATH; do
        [[ -z "$d" ]] && continue
        cand="$d/nasm"
        if [[ -x "$cand" ]]; then
            cand_dir=$(cd "$d" 2>/dev/null && pwd)
            [[ "$cand_dir" == "$self_dir" ]] && continue
            real_nasm="$cand"
            break
        fi
    done
    IFS="$saved_ifs"
fi

if [[ -z "$real_nasm" ]]; then
    echo "[nasm-macho-wrapper] error: real nasm not found (set MR_REAL_NASM)" >&2
    exit 127
fi

# 2. 检查输出格式是否为 macho, 以及是否已存在 build_version。
is_macho=0
has_build_version=0
prev=
for a in "$@"; do
    case "$a" in
        -fmacho*|--macho*) is_macho=1 ;;
        macho32|macho64)   [[ "$prev" == "-f" ]] && is_macho=1 ;;
    esac
    case "$a" in
        *build_version*) has_build_version=1 ;;
    esac
    prev="$a"
done

# 非 macho 输出 (Android/Linux elf 等) 或已含 build_version -> 原样透传。
if [[ "$is_macho" != "1" || "$has_build_version" == "1" ]]; then
    exec "$real_nasm" "$@"
fi

# 3. 推导平台 token 与最低系统版本。
plat=
case "$MR_PLAT" in
    macos) plat="macos" ;;
    ios)   [[ "$MR_IS_SIMULATOR" == "1" ]] && plat="iossimulator" || plat="ios" ;;
    tvos)  [[ "$MR_IS_SIMULATOR" == "1" ]] && plat="tvossimulator" || plat="tvos" ;;
esac

ver="$MR_DEPLOYMENT_TARGET_VER"          # 例如 10.14 / 12.0
maj="${ver%%.*}"                         # 10
rest="${ver#*.}"                         # 14 (或 14.0)
min="${rest%%.*}"                        # 14
[[ "$ver" != *.* ]] && min="0"           # 无小数点时补 0

# 平台/版本推导不出来 -> 安全透传, 不注入。
if [[ -z "$plat" || -z "$maj" || -z "$min" ]]; then
    exec "$real_nasm" "$@"
fi

# 4. 版本守卫: nasm >= 2.16 才支持 build_version。低于则透传并提示一次。
nasm_ver=$("$real_nasm" -v 2>/dev/null | sed -n 's/^NASM version \([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')
nver_maj=$(echo "$nasm_ver" | awk '{print $1}')
nver_min=$(echo "$nasm_ver" | awk '{print $2}')
supports_bv=0
if [[ -n "$nver_maj" ]]; then
    if (( nver_maj > 2 )) || { (( nver_maj == 2 )) && (( nver_min >= 16 )); }; then
        supports_bv=1
    fi
fi

if [[ "$supports_bv" != "1" ]]; then
    if [[ -z "$_NASM_WRAPPER_WARNED" ]]; then
        echo "[nasm-macho-wrapper] warning: nasm ${nver_maj:-?}.${nver_min:-?} < 2.16, cannot emit LC_BUILD_VERSION; link warnings may persist. Consider: brew upgrade nasm" >&2
        export _NASM_WRAPPER_WARNED=1
    fi
    exec "$real_nasm" "$@"
fi

# 5. 注入 build_version 并执行真实 nasm。
exec "$real_nasm" --before "build_version ${plat}, ${maj}, ${min}" "$@"
