#!/bin/bash
set -e

echo "=== 1. 初始化并配置各个 FFmpeg 版本 ==="
#./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64

echo "=== 2. 创建发布目录并同步静态文件 ==="
OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"
touch "$OUTPUT_DIR/.nojekyll"

# 同步全局样式与 Portal 首页
cp -f ./tools/GitHub-2025.css "$OUTPUT_DIR/GitHub-2025.css"
if [ -f "./tools/index.html" ]; then
    cp -f ./tools/index.html "$OUTPUT_DIR/index.html"
fi

# 通用模板渲染函数：将 Markdown 内容填充到 HTML 模板中
render_page() {
    local template="$1"
    local md_file="$2"
    local output="$3"
    python3 -c "
import sys
template = open(sys.argv[1], 'r', encoding='utf-8').read()
content = open(sys.argv[2], 'r', encoding='utf-8').read()
output = template.replace('{{MARKDOWN_CONTENT}}', content)
open(sys.argv[3], 'w', encoding='utf-8').write(output)
" "$template" "$md_file" "$output"
}

echo "=== 3. 生成 Feature Evolution Matrix 网页 (feature-matrix.html) ==="
TMP_MATRIX_MD=$(mktemp /tmp/ffmpeg_matrix.XXXXXX)
cat ./tools/markdown/feature-matrix-header.md > "$TMP_MATRIX_MD"
./tools/list-all-feature.sh >> "$TMP_MATRIX_MD"
render_page ./tools/templates/feature-matrix.html "$TMP_MATRIX_MD" "$OUTPUT_DIR/feature-matrix.html"
rm -f "$TMP_MATRIX_MD"

echo "=== 4. 生成 Player Compatibility 网页 (player-compatibility.html) ==="
render_page ./tools/templates/player-compatibility.html ./tools/markdown/player-compatibility.md "$OUTPUT_DIR/player-compatibility.html"

echo "=== 5. 生成 Virtual Test Sources 网页 (virtual-sources.html) ==="
render_page ./tools/templates/virtual-sources.html ./tools/markdown/virtual-sources.md "$OUTPUT_DIR/virtual-sources.html"

echo "🎉 发布成功！Portal 首页、功能矩阵页、播放器兼容性页与专属虚拟源测试页已生成至 ./$OUTPUT_DIR/ 目录。"