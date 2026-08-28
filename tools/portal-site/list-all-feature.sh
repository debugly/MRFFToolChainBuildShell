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

VERSIONS_CFG = [
    ('8', 'ffmpeg8.sh'),
    ('7', 'ffmpeg7.sh'),
    ('6', 'ffmpeg6.sh'),
    ('5', 'ffmpeg5.sh'),
    ('4', 'ffmpeg4.sh'),
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

def load_versions():
    versions_data = []
    for vnum, cfg_file in VERSIONS_CFG:
        cfg_path = os.path.join(CONFIGS_DIR, cfg_file)
        tag = ''
        ver = ''
        if os.path.isfile(cfg_path):
            with open(cfg_path, 'r', encoding='utf-8') as f:
                for line in f:
                    m_tag = re.search(r'export PRE_COMPILE_TAG_MACOS=(\S+)', line)
                    if m_tag:
                        tag = m_tag.group(1).strip('\"\'')
                    m_ver = re.search(r'export GIT_REPO_VERSION=(\S+)', line)
                    if m_ver:
                        ver = m_ver.group(1).strip('\"\'')

        configure_path = os.path.join(SRC_DIR, f'ffmpeg{vnum}-arm64', 'configure')
        zip_path = os.path.join(PRE_DIR, tag, f'ffmpeg{vnum}-macos-universal-{ver}.zip')
        
        # Check if zip exists; if not, try to search in tag directory
        if not os.path.isfile(zip_path) and os.path.isdir(os.path.join(PRE_DIR, tag)):
            candidates = [os.path.join(PRE_DIR, tag, f) for f in os.listdir(os.path.join(PRE_DIR, tag)) if f.endswith('.zip')]
            if candidates:
                zip_path = candidates[0]

        # If still missing, try auto-downloading from GitHub releases
        if not os.path.isfile(zip_path) and tag and ver:
            os.makedirs(os.path.join(PRE_DIR, tag), exist_ok=True)
            download_url = f"https://github.com/debugly/MRFFToolChainBuildShell/releases/download/{tag}/ffmpeg{vnum}-macos-universal-{ver}.zip"
            try:
                print(f"[!] Downloading precompiled package {tag}...", file=sys.stderr)
                urllib.request.urlretrieve(download_url, zip_path)
            except Exception as e:
                print(f"[!] Failed to auto-download {download_url}: {e}", file=sys.stderr)

        enabled_macros = set()
        if os.path.isfile(zip_path):
            try:
                with zipfile.ZipFile(zip_path, 'r') as z:
                    content = ''
                    for header in ['ffmpeg/include/libffmpeg/config.h', 'ffmpeg/include/libffmpeg/config_components.h']:
                        if header in z.namelist():
                            content += z.read(header).decode('utf-8', errors='ignore') + '\n'
                    for m in re.finditer(r'#define\s+(CONFIG_\w+)\s+1', content):
                        enabled_macros.add(m.group(1))
            except Exception as e:
                print(f"[!] Warning reading zip {zip_path}: {e}", file=sys.stderr)

        versions_data.append({
            'version': ver if ver else f'{vnum}.x',
            'configure': configure_path,
            'enabled_macros': enabled_macros
        })
    return versions_data

def process_feature(versions_data, list_cmd, title_name, type_suffix):
    headers = []
    raw_files = []

    for v in versions_data:
        cfg = v['configure']
        if not os.path.isfile(cfg) or not os.access(cfg, os.X_OK):
            raw_files.append([])
            headers.append(f"{v['version']} (N/A)")
        else:
            res = subprocess.run([cfg, list_cmd], capture_output=True, text=True)
            items = sorted(list(set([x for x in res.stdout.split() if x])))
            raw_files.append(items)

            enabled_cnt = sum(1 for item in items if f"CONFIG_{item.upper()}_{type_suffix}" in v['enabled_macros'])
            total_cnt = len(items)
            headers.append(f"{v['version']} ({enabled_cnt}/{total_cnt})")

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