#!/bin/bash

# 确保脚本遇到错误时立即停止
set -e

echo "=== 1. 初始化并编译/配置各个 FFmpeg 版本 ==="
./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64 --skip-pull-base

echo "=== 2. 创建发布目录 ==="
# GitHub Pages 默认支持根目录或 docs 目录，这里我们统一生成到 docs/
OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"

echo "=== 3. 生成带 Front Matter 的 index.md ==="
# 写入 GitHub Pages / Jekyll 所需的元数据头部
cat << 'EOF' > "$OUTPUT_DIR/index.md"
---
layout: default
title: FFmpeg Evolution Matrix (macOS arm64)
description: A comprehensive feature comparison matrix between FFmpeg 4.x, 5.x, 6.x, 7.x, and 8.x.
permalink: /
---

# FFmpeg Feature Evolution Matrix (macOS arm64)

> [!NOTE]
> This page is automatically generated. It compares the availability of protocols, codecs, filters, and other features across different FFmpeg versions.
> **Columns from left to right:** Newest (8.1.2) to Oldest (4.0.5). Blanks on the right indicate newly added features in that version.

EOF

# 追加原有的矩阵表格生成脚本的输出
./tools/list-all-feature.sh >> "$OUTPUT_DIR/index.md"

echo "=== 4. 生成附加说明文件 ==="
# 顺手生成一个简易的本地预览配置文件（防止 Jekyll 忽略下划线文件）
echo "include: [_pages, _columns]" > "$OUTPUT_DIR/_config.yml"

echo "🎉 完善成功！内容已生成至 ./$OUTPUT_DIR/index.md"