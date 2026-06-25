#!/bin/bash

# 确保脚本遇到错误时立即停止
set -e

echo "=== 1. 初始化并编译/配置各个 FFmpeg 版本 ==="
./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64

echo "=== 2. 创建发布目录 ==="
OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"

echo "=== 3. 解决自定义域名与路由冲突 (关键修复) ==="
# 1. 彻底禁用 Jekyll 编译，防止它乱动 permalink 路由
touch "$OUTPUT_DIR/.nojekyll"

# 2. 【核心】如果你的当前仓库在 Settings 绑定了自定义域名，请把下面这行的注释解开，并换成你的域名：
# echo "debugly.github.io" > "$OUTPUT_DIR/CNAME"


echo "=== 4. 生成 index.md (去掉了干扰路由的 Front Matter) ==="
# 回归最纯粹的 Markdown 头部，靠 GitHub 原生渲染，不再加任何 permalink
cat << 'EOF' > "$OUTPUT_DIR/index.md"
# FFmpeg Feature Evolution Matrix (macOS arm64)

> [!NOTE]
> This page is automatically generated. It compares the availability of protocols, codecs, filters, and other features across different FFmpeg versions.
> **Columns from left to right:** Newest (8.1.2) to Oldest (4.0.5). Blanks on the right indicate newly added features in that version.

EOF

# 追加原有的矩阵表格生成脚本的输出
./tools/list-all-feature.sh >> "$OUTPUT_DIR/index.md"

echo "🎉 针对自定义域名优化成功！内容已生成至 ./$OUTPUT_DIR/index.md"