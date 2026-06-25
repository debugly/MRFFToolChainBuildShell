#!/bin/bash
set -e

echo "=== 1. 初始化并配置各个 FFmpeg 版本 ==="
./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64

echo "=== 2. 创建发布目录 ==="
OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"
touch "$OUTPUT_DIR/.nojekyll"

echo "=== 3. 生成临时 Markdown 矩阵数据 ==="
TMP_MD_DATA=$(mktemp /tmp/ffmpeg_md.XXXXXX)

cat << 'EOF' > "$TMP_MD_DATA"
# FFmpeg Feature Evolution Matrix (macOS arm64)

> [!NOTE]
> This page is automatically generated. It compares the availability of protocols, codecs, filters, and other features across different FFmpeg versions.
> **Columns from left to right:** Newest (8.1.2) to Oldest (4.0.5). Blanks on the right indicate newly added features in that version.
EOF

# 追加原本的对齐矩阵
./tools/list-all-feature.sh >> "$TMP_MD_DATA"

echo "=== 4. 完美融入 GitHub-2025.css 生成原生 index.html ==="
MD_CONTENT=$(cat "$TMP_MD_DATA")

# 直接利用本地的 GitHub-2025.css 拼接出最终网页
cat << EOF > "$OUTPUT_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>FFmpeg Evolution Matrix</title>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
$(cat ./tools/GitHub-2025.css)

        /* 在原生样式基础上，额外追加大屏幕居中和响应式间距优化 */
        body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 1200px;
            margin: 0 auto;
            padding: 45px;
        }
        @media (max-width: 767px) {
            body { padding: 15px; }
        }
        .markdown-body table {
            display: table;
            width: 100%;
        }
    </style>
</head>
<body class="markdown-body">

    <article id="content">
        </article>

    <script type="text/markdown" id="markdown-source">
${MD_CONTENT}
    </script>

    <script>
        // 从标签读取原始 markdown 并进行完美的客户端渲染
        const src = document.getElementById('markdown-source').innerHTML;
        document.getElementById('content').innerHTML = marked.parse(src);
    </script>
</body>
</html>
EOF

rm -f "$TMP_MD_DATA"
echo "🎉 融合 GitHub-2025.css 成功！完美的原生体验网页已生成至 ./$OUTPUT_DIR/index.html"