#!/bin/bash

# 获取当前脚本所在目录并切换
SHELL_ROOT=$(cd "$(dirname "$0")" && pwd)
cd "$SHELL_ROOT"
cd ../build/src/macos

# 定义 FFmpeg 版本及其对应的配置路径
# 顺序必须从新到旧：左边最新，右边最老
VERSIONS=(
    "8.1.2|./ffmpeg8-arm64/configure"
    "7.1.3|./ffmpeg7-arm64/configure"
    "6.1.1|./ffmpeg6-arm64/configure"
    "5.1.6|./ffmpeg5-arm64/configure"
    "4.0.5|./ffmpeg4-arm64/configure"
)

# 创建临时文件夹
TMP_DIR=$(mktemp -d /tmp/ffmpeg_perfect.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

# ==========================================
# 特征处理主函数（采用全局大列表对齐算法）
# ==========================================
process_feature() {
    local list_cmd="$1"
    local title_name="$2"

    local headers=()
    local raw_files=()
    local total_versions=${#VERSIONS[@]}

    # 1. 收集所有版本的数据（单行、排序、去重）
    for i in "${!VERSIONS[@]}"; do
        local version="${VERSIONS[i]%%|*}"
        local config_path="${VERSIONS[i]##*|}"
        local raw_file="$TMP_DIR/raw_$i"

        if [ ! -x "$config_path" ]; then
            touch "$raw_file"
            headers+=("$version (N/A)")
        else
            local raw_output
            raw_output=$($config_path "$list_cmd" 2>/dev/null)
            echo "$raw_output" | tr -s '[:space:]' '\n' | grep -v '^$' | sort -u > "$raw_file"
            
            local count
            count=$(wc -l < "$raw_file" | tr -d ' ')
            headers+=("$version ($count)")
        fi
        raw_files+=("$raw_file")
    done

    # 2. 构建完美的全局统一基准列表 (Master List)
    local master_list="$TMP_DIR/master_list"
    local left_items="$TMP_DIR/left_items"
    local deleted_items="$TMP_DIR/deleted_items"
    
    # 2.1 优先以最左边最新版 (raw_0) 的内容作为上半部分基准
    cat "${raw_files[0]}" > "$left_items"
    
    # 2.2 把其他所有老版本里有、但新版里没有的遗留/废弃项收集起来
    > "$deleted_items"
    for (( i=1; i<total_versions; i++ )); do
        cat "${raw_files[$i]}" >> "$deleted_items"
    done
    
    # 2.3 对废弃项进行去重和排序，确保表格下半部分也整齐美观
    local cleaned_deleted="$TMP_DIR/cleaned_deleted"
    sort -u "$deleted_items" | while IFS= read -r old_item; do
        if ! grep -Fqx "$old_item" "$left_items"; then
            echo "$old_item"
        fi
    done | sort > "$cleaned_deleted"
    
    # 2.4 合体：上半部分是新版有序列表，下半部分是旧版废弃有序列表
    cat "$left_items" "$cleaned_deleted" > "$master_list"

    # 3. 打印 Markdown 表格头部
    echo "## $title_name"
    echo ""
    
    local header_line="|"
    local divider_line="|"
    for h in "${headers[@]}"; do
        header_line="$header_line $h |"
        divider_line="$divider_line --- |"
    done
    echo "$header_line"
    echo "$divider_line"

    # 4. 遍历全局基准大列表，进行多版本精准查岗并输出
    while IFS= read -r feature_name || [[ -n "$feature_name" ]]; do
        # 确保不处理空白行
        [ -z "$feature_name" ] && continue

        local row_output="|"
        # 检查每个版本中是否存在这个特征
        for i in "${!VERSIONS[@]}"; do
            if grep -Fqx "$feature_name" "${raw_files[$i]}"; then
                row_output="$row_output $feature_name |"
            else
                row_output="$row_output  |"
            fi
        done
        echo "$row_output"
    done < "$master_list"
    
    echo ""
}

# ==========================================
# 各功能模块的独立路由函数
# ==========================================
show_protocols() { process_feature "--list-protocols" "Protocols"; }
show_encoders()  { process_feature "--list-encoders" "Encoders"; }
show_decoders()  { process_feature "--list-decoders" "Decoders"; }
show_demuxers()  { process_feature "--list-demuxers" "Demuxers"; }
show_muxers()    { process_feature "--list-muxers" "Muxers"; }
show_filters()   { process_feature "--list-filters" "Filters"; }
show_bsfs()      { process_feature "--list-bsfs" "Bitstream Filters"; }
show_hwaccels()  { process_feature "--list-hwaccels" "Hardware Accelerators"; }
show_indevs()    { process_feature "--list-indevs" "Input Devices"; }
show_outdevs()   { process_feature "--list-outdevs" "Output Devices"; }
show_parsers()   { process_feature "--list-parsers" "Parsers"; }

show_usage() {
    echo "Usage: $0 [feature]"
    echo "Available features:"
    echo "  protocols, encoders, decoders, demuxers, muxers, filters,"
    echo "  bsfs, hwaccels, indevs, outdevs, parsers, all"
}

# ==========================================
# Main 主控入口
# ==========================================
main() {
    local action="${1:-all}"
    case "$action" in
        protocols)  show_protocols ;;
        encoders)   show_encoders ;;
        decoders)   show_decoders ;;
        demuxers)   show_demuxers ;;
        muxers)     show_muxers ;;
        filters)    show_filters ;;
        bsfs)       show_bsfs ;;
        hwaccels)   show_hwaccels ;;
        indevs)     show_indevs ;;
        outdevs)    show_outdevs ;;
        parsers)    show_parsers ;;
        all)
            echo "# FFmpeg Evolution Comparison"
            show_protocols; show_encoders; show_decoders; show_demuxers
            show_muxers; show_filters; show_bsfs; show_hwaccels
            show_indevs; show_outdevs; show_parsers
            ;;
        -h|--help) show_usage; exit 0 ;;
        *) echo "Error: Unknown feature '$action'" >&2; show_usage; exit 1 ;;
    esac
}

main "$@"