#!/bin/bash
# ==============================================================================
# 脚本名称: main.sh
# 脚本定位: 一键生成诊断门户网站（Portal）脚本
#
# 核心功能:
#   1. 初始化/校验各版本 FFmpeg 源码配置环境（ffmpeg4 ~ ffmpeg8）。
#   2. 生成并发布一整套交互式静态站点至 ./build/docs/ 目录（用于 GitHub Pages 部署）：
#      - build/docs/index.html: 门户首页看板（平台、版本、分类、库统计及页面入口）
#      - build/docs/feature-matrix.html: 特性演进对比矩阵（含删除线对比、分类快捷跳转面板、置顶等）
#      - build/docs/feature-matrix.md: 纯 Markdown 格式的特性演进对比矩阵
#      - build/docs/player-compatibility.html: 播放器兼容性与编码陷阱验证测试集
#      - build/docs/virtual-sources.html: FFmpeg 内置虚拟测试源展示页（带交互播放控件）
#      - build/docs/GitHub-2025.css & .nojekyll: 全局样式及 GitHub Pages 路由配置
#
# 适用场景:
#   - CI/CD 自动化构建（.github/workflows/generate portal website.yaml）
#   - 本地完整预览与生成 GitHub Pages 门户站点
# ==============================================================================
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WORKSPACE_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
cd "$WORKSPACE_ROOT"

echo "=== 1. 检查并初始化各个 FFmpeg 版本 ==="
NEED_INIT=0
for v in ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8; do
    if [ ! -f "./build/src/macos/${v}-arm64/configure" ]; then
        NEED_INIT=1
        break
    fi
done

if [ "$NEED_INIT" -eq 1 ]; then
    echo "检测到部分 FFmpeg 源码未初始化，正在执行初始化与配置..."
    ./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64 --skip-pull-base
else
    echo "所有 FFmpeg 源码均已初始化，跳过 init。"
fi

echo "=== 2. 创建发布目录 ==="
OUTPUT_DIR="${1:-build/docs}"
mkdir -p "$OUTPUT_DIR"

echo "=== 3. 解决自定义域名与路由冲突 (关键修复) ==="
# 1. 彻底禁用 Jekyll 编译，防止它乱动 permalink 路由
touch "$OUTPUT_DIR/.nojekyll"

# 2. 【核心】如果你的当前仓库在 Settings 绑定了自定义域名，请把下面这行的注释解开，并换成你的域名：
# echo "debugly.github.io" > "$OUTPUT_DIR/CNAME"

echo "=== 4. 同步静态文件与全局样式 ==="
cp -f "$SCRIPT_DIR/GitHub-2025.css" "$OUTPUT_DIR/GitHub-2025.css"
cp -f "$SCRIPT_DIR/index.html" "$OUTPUT_DIR/index.html"

echo "=== 5. 动态生成测试验证与虚拟源视频资产 ==="
"$SCRIPT_DIR/generate-test-videos.sh" 15 "$OUTPUT_DIR/videos" || echo "⚠️ 视频生成遇到警告或跳过"

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

echo "=== 6. 生成 Feature Evolution Matrix 网页 (feature-matrix.html) 与 feature-matrix.md ==="
TMP_MATRIX_MD=$(mktemp /tmp/ffmpeg_matrix.XXXXXX)
cat "$SCRIPT_DIR/markdown/feature-matrix-header.md" > "$TMP_MATRIX_MD"
"$SCRIPT_DIR/list-all-feature.sh" >> "$TMP_MATRIX_MD"
render_page "$SCRIPT_DIR/templates/feature-matrix.html" "$TMP_MATRIX_MD" "$OUTPUT_DIR/feature-matrix.html"
cp -f "$TMP_MATRIX_MD" "$OUTPUT_DIR/feature-matrix.md"
rm -f "$TMP_MATRIX_MD"

echo "=== 7. 生成 Player Compatibility 网页 (player-compatibility.html) ==="
render_page "$SCRIPT_DIR/templates/player-compatibility.html" "$SCRIPT_DIR/markdown/player-compatibility.md" "$OUTPUT_DIR/player-compatibility.html"

echo "=== 8. 生成 Virtual Test Sources 网页 (virtual-sources.html) ==="
render_page "$SCRIPT_DIR/templates/virtual-sources.html" "$SCRIPT_DIR/markdown/virtual-sources.md" "$OUTPUT_DIR/virtual-sources.html"

echo "🎉 发布成功！Portal 首页、功能矩阵页、Markdown、播放器兼容性页与专属虚拟源测试页已生成至 ./$OUTPUT_DIR/ 目录。"
