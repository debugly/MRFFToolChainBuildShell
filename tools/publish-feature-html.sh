#!/bin/bash
set -e

echo "=== 1. 初始化并配置各个 FFmpeg 版本 ==="
./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64

echo "=== 2. 创建发布目录 ==="
OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"

# 强制禁用 Jekyll，全面拥抱纯静态
touch "$OUTPUT_DIR/.nojekyll"

echo "=== 3. 生成临时 Markdown 矩阵 ==="
TMP_MD="$OUTPUT_DIR/raw_matrix.md"

cat << 'EOF' > "$TMP_MD"
# FFmpeg Feature Evolution Matrix (macOS arm64)

> **Columns from left to right:** Newest (8.1.2) to Oldest (4.0.5). Blanks on the right indicate newly added features in that version.

EOF

# 追加原有的矩阵表格生成脚本的输出
./tools/list-all-feature.sh >> "$TMP_MD"


echo "=== 4. 【核心修复】将 Markdown 转换为原生的 index.html ==="
# 使用 python3 将 Markdown 渲染为标准 HTML，并套上一个精美的、支持 Markdown 表格的 CSS 主题
python3 -c "
import markdown
with open('$TMP_MD', 'r', encoding='utf-8') as f:
    html_content = markdown.markdown(f.read(), extensions=['tables'])

full_html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset=\"utf-8\">
    <title>FFmpeg Evolution Matrix</title>
    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.1/github-markdown.min.css\">
    <style>
        body {{
            box-sizing: border-box;
            min-width: 200px;
            max-width: 1200px;
            margin: 0 auto;
            padding: 45px;
        }}
        @media (max-width: 767px) {{
            body {{ padding: 15px; }}
        }}
        .markdown-body table {{
            display: table;
            width: 100%;
        }}
    </style>
</head>
<body>
    <article class=\"markdown-body\">
        {html_content}
    </article>
</body>
</html>'''

with open('$OUTPUT_DIR/index.html', 'w', encoding='utf-8') as f:
    f.write(full_html)
"

# 打扫战场，删掉临时的 md 文件
rm -f "$TMP_MD"

echo "🎉 终极优化成功！标准网页已生成至 ./$OUTPUT_DIR/index.html"