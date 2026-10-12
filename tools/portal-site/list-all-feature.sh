#!/bin/bash

# 获取当前脚本所在目录并切换
SHELL_ROOT=$(cd "$(dirname "$0")" && pwd)
cd "$SHELL_ROOT"

python3 - "$@" << 'EOF'
import os
import sys
import re
import zipfile
import subprocess
import urllib.request

SHELL_ROOT = os.path.dirname(os.path.abspath(__file__)) if '__file__' in globals() else os.getcwd()
WORKSPACE_ROOT = os.path.abspath(os.path.join(SHELL_ROOT, '..', '..'))
SRC_DIR = os.path.join(WORKSPACE_ROOT, 'build', 'src', 'macos')
PRE_DIR = os.path.join(WORKSPACE_ROOT, 'build', 'pre')
CONFIGS_DIR = os.path.join(WORKSPACE_ROOT, 'configs', 'libs')
# configure 的临时镜像目录，见 prepare_scratch_source()
SCRATCH_ROOT = os.path.join(WORKSPACE_ROOT, 'build', 'ffbuild-portal')

# 特性列表以 macOS arm64 的 configure 为准（同一版本各平台组件表相同）
ARCH = 'arm64'

# (版本号, 配置文件)，enable/disable 状态取自该平台的预编译包
VERSIONS_CFG = [
    ('8', 'ffmpeg8.sh'),
    ('7', 'ffmpeg7.sh'),
    ('6', 'ffmpeg6.sh'),
    ('5', 'ffmpeg5.sh'),
    ('4', 'ffmpeg4.sh'),
]

# 追加列：与上面的版本共用源码，但 enable/disable 状态读该平台自己的预编译包
# (版本号, 配置文件, PRE_COMPILE_TAG_* 的平台名, 包名前缀里的平台名, 列名)
PLATFORM_COLUMNS = [
    ('8', 'ffmpeg8.sh', 'ANDROID', 'android', 'Android'),
    ('8', 'ffmpeg8.sh', 'OHOS', 'ohos', 'HarmonyOS'),
]

CATEGORIES = [
    ('decoders', '--list-decoders', 'Decoders', 'DECODER'),
    ('demuxers', '--list-demuxers', 'Demuxers', 'DEMUXER'),
    ('protocols', '--list-protocols', 'Protocols', 'PROTOCOL'),
    ('hwaccels', '--list-hwaccels', 'Hardware Accelerators', 'HWACCEL'),
    ('filters', '--list-filters', 'Filters', 'FILTER'),
    ('bsfs', '--list-bsfs', 'Bitstream Filters', 'BSF'),
    ('parsers', '--list-parsers', 'Parsers', 'PARSER'),
    ('muxers', '--list-muxers', 'Muxers', 'MUXER'),
    ('encoders', '--list-encoders', 'Encoders', 'ENCODER'),
    ('indevs', '--list-indevs', 'Input Devices', 'INDEV'),
    ('outdevs', '--list-outdevs', 'Output Devices', 'OUTDEV'),
]

def parse_lib_config(cfg_file):
    """读取 configs/libs/<cfg_file> 里的 GIT_REPO_VERSION 和所有 PRE_COMPILE_TAG_<PLAT>"""
    ver = ''
    tags = {}
    cfg_path = os.path.join(CONFIGS_DIR, cfg_file)
    if os.path.isfile(cfg_path):
        with open(cfg_path, 'r', encoding='utf-8') as f:
            for line in f:
                m_tag = re.search(r'export PRE_COMPILE_TAG_(\w+)=(\S+)', line)
                if m_tag:
                    tags[m_tag.group(1)] = m_tag.group(2).strip('\"\'')
                m_ver = re.search(r'export GIT_REPO_VERSION=(\S+)', line)
                if m_ver:
                    ver = m_ver.group(1).strip('\"\'')
    return ver, tags

def locate_prebuilt_zip(tag, vnum, slug, ver):
    """精确文件名 → 同平台（同版本号）的其它包 → 从 GitHub releases 下载"""
    tag_dir = os.path.join(PRE_DIR, tag)
    zip_path = os.path.join(tag_dir, f'ffmpeg{vnum}-{slug}-universal-{ver}.zip')

    # 同一个 tag 的 release 里放了好几个平台的包，所以只挑同平台的
    if not os.path.isfile(zip_path) and os.path.isdir(tag_dir):
        pat = re.compile(r'^ffmpeg%s-%s-universal-.*\.zip$' % (vnum, re.escape(slug)))
        candidates = [os.path.join(tag_dir, f) for f in sorted(os.listdir(tag_dir)) if pat.match(f)]
        if candidates:
            zip_path = candidates[0]

    if not os.path.isfile(zip_path) and tag and ver:
        os.makedirs(tag_dir, exist_ok=True)
        download_url = f"https://github.com/debugly/MRFFToolChainBuildShell/releases/download/{tag}/ffmpeg{vnum}-{slug}-universal-{ver}.zip"
        try:
            print(f"[!] Downloading precompiled package {tag} ({slug})...", file=sys.stderr)
            urllib.request.urlretrieve(download_url, zip_path)
        except Exception as e:
            print(f"[!] Failed to auto-download {download_url}: {e}", file=sys.stderr)

    return zip_path

def config_header_paths(names, arch=ARCH):
    """Apple 的包是 universal（ffmpeg/include/...），Android/OHOS 的包是按架构分的（ffmpeg/ffmpeg-arm64/include/...）"""
    picked = []
    for suffix in ('include/libffmpeg/config.h', 'include/libffmpeg/config_components.h'):
        candidates = [n for n in names if n.endswith(suffix)]
        arch_candidates = [n for n in candidates if f'ffmpeg-{arch}/' in n]
        if arch_candidates:
            picked.append(sorted(arch_candidates)[0])
        elif candidates:
            picked.append(sorted(candidates, key=len)[0])
    return picked

def read_enabled_macros(zip_path):
    enabled_macros = set()
    if os.path.isfile(zip_path):
        try:
            with zipfile.ZipFile(zip_path, 'r') as z:
                names = z.namelist()
                content = ''
                for header in config_header_paths(names):
                    content += z.read(header).decode('utf-8', errors='ignore') + '\n'
                for m in re.finditer(r'#define\s+(CONFIG_\w+)\s+1', content):
                    enabled_macros.add(m.group(1))
        except Exception as e:
            print(f"[!] Warning reading zip {zip_path}: {e}", file=sys.stderr)
    return enabled_macros

def make_column(vnum, label, tag, slug, ver):
    return {
        'label': label,
        'configure': os.path.join(SRC_DIR, f'ffmpeg{vnum}-arm64', 'configure'),
        'enabled_macros': read_enabled_macros(locate_prebuilt_zip(tag, vnum, slug, ver)),
    }

def prepare_scratch_source(source_dir):
    """FFmpeg 的 configure 只允许「源目录里没有 config.h」时做 out-of-tree 构建，
    而本地 build/src 下的源码树经常被就地 configure 过（有 config.h），
    那样跑出来的就是 help 文本而不是组件表。这里在 build/ 下搭一个全是软链接的镜像目录，
    让 configure 认为自己是 in-source 构建：组件表照样从真实源码里扫出来，
    写出的 config.h / ffbuild 落在镜像目录，绝不碰真实源码树。"""
    scratch_dir = os.path.join(SCRATCH_ROOT, os.path.basename(source_dir))
    keep_out = {'config.h', 'config_components.h', 'config.mak', 'config.log', 'ffbuild', '.git'}
    os.makedirs(scratch_dir, exist_ok=True)
    for entry in os.listdir(source_dir):
        if entry in keep_out:
            continue
        link_path = os.path.join(scratch_dir, entry)
        if not os.path.lexists(link_path):
            os.symlink(os.path.join(source_dir, entry), link_path)
    return scratch_dir

def list_components(configure_path, list_cmd):
    """返回该版本 configure 的组件清单；源码没初始化或跑不起来时返回 None"""
    if not os.path.isfile(configure_path) or not os.access(configure_path, os.X_OK):
        return None

    source_dir = os.path.dirname(configure_path)
    try:
        scratch_dir = prepare_scratch_source(source_dir)
        res = subprocess.run(['./configure', list_cmd], cwd=scratch_dir,
                             capture_output=True, text=True)
    except Exception as e:
        print(f"[!] Warning running {configure_path} {list_cmd}: {e}", file=sys.stderr)
        return None

    items = sorted(set(x for x in res.stdout.split() if x))
    # configure 失败时会把用法/帮助文本打到 stdout，这种输出不是组件表
    if res.returncode != 0 or not items or 'Usage:' in res.stdout:
        print(f"[!] Warning: {configure_path} {list_cmd} failed, skip this column", file=sys.stderr)
        return None
    return items

def load_versions():
    versions_data = []

    # 追加列按版本号挂到对应版本后面
    platform_columns = {}
    for vnum, cfg_file, plat_key, slug, name in PLATFORM_COLUMNS:
        ver, tags = parse_lib_config(cfg_file)
        platform_columns.setdefault(vnum, []).append((plat_key, slug, name, ver, tags))

    for vnum, cfg_file in VERSIONS_CFG:
        ver, tags = parse_lib_config(cfg_file)
        version_text = ver if ver else f'{vnum}.x'
        versions_data.append(make_column(vnum, version_text, tags.get('MACOS', ''), 'macos', ver))

        for plat_key, slug, name, plat_ver, plat_tags in platform_columns.get(vnum, []):
            plat_version_text = plat_ver if plat_ver else version_text
            versions_data.append(make_column(
                vnum, f'{name} {plat_version_text}', plat_tags.get(plat_key, ''), slug, plat_ver))

    return versions_data

def process_feature(versions_data, list_cmd, title_name, type_suffix):
    headers = []
    raw_files = []

    for v in versions_data:
        items = list_components(v['configure'], list_cmd)
        if items is None:
            raw_files.append([])
            headers.append(f"{v['label']} (N/A)")
        else:
            raw_files.append(items)

            enabled_cnt = sum(1 for item in items if f"CONFIG_{item.upper()}_{type_suffix}" in v['enabled_macros'])
            total_cnt = len(items)
            headers.append(f"{v['label']} ({enabled_cnt}/{total_cnt})")

    left_items = list(raw_files[0]) if raw_files else []
    left_set = set(left_items)

    deleted_items = set()
    for items in raw_files[1:]:
        for item in items:
            if item not in left_set:
                deleted_items.add(item)
    master_list = left_items + sorted(list(deleted_items))

    lines = []
    lines.append(f"## {title_name}\n")

    header_line = "| " + " | ".join(headers) + " |"
    divider_line = "| " + " | ".join(["---"] * len(headers)) + " |"
    lines.append(header_line)
    lines.append(divider_line)

    for feature_name in master_list:
        row = []
        for i, v in enumerate(versions_data):
            if feature_name in raw_files[i]:
                macro = f"CONFIG_{feature_name.upper()}_{type_suffix}"
                if macro in v['enabled_macros']:
                    row.append(feature_name)
                else:
                    row.append(f"~~{feature_name}~~")
            else:
                row.append("")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")
    return "\n".join(lines)

def show_usage():
    print("Usage: tools/list-all-feature.sh [feature]")
    print("Available features:")
    print("  decoders, demuxers, protocols, hwaccels, filters,")
    print("  bsfs, parsers, muxers, encoders, indevs, outdevs, all")

def main():
    args = sys.argv[1:]
    action = args[0] if args else "all"

    if action in ["-h", "--help"]:
        show_usage()
        sys.exit(0)

    category_map = {cat[0]: cat for cat in CATEGORIES}

    if action != "all" and action not in category_map:
        print(f"Error: Unknown feature '{action}'", file=sys.stderr)
        show_usage()
        sys.exit(1)

    versions_data = load_versions()

    if action == "all":
        print("---\n")
        for key, list_cmd, title_name, type_suffix in CATEGORIES:
            print(process_feature(versions_data, list_cmd, title_name, type_suffix))
    else:
        key, list_cmd, title_name, type_suffix = category_map[action]
        print(process_feature(versions_data, list_cmd, title_name, type_suffix))

if __name__ == "__main__":
    main()
EOF
