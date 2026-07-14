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

# 追加测试视频套件说明及下载链接
cat << 'EOF' >> "$TMP_MD_DATA"

---

# 🎬 Player Compatibility & Encoding Pitfalls Validation Suite

This test suite presents the most common video/audio encoding pitfalls in player hardware/software compatibility, generated dynamically using our custom **FFmpeg 8-bin**. Download and test these samples on your target players (QuickTime, Safari, VLC, Chrome, iOS/Android Native Player) to witness the compatibility differences!

> [!TIP]
> 🌈 **FFmpeg Virtual Test Sources Showcase**: We have generated high-quality demo videos for all available virtual test sources (like Mandelbrot fractal, dynamic gradients, custom test patterns, etc.) compiled into our binary. Since it is extremely rich, we have put them in a dedicated page: **[Explore FFmpeg Virtual Sources & Patterns ➜](virtual-sources.html)**

## 1. HEVC/H.265 Tagging Compatibility (Apple Safari & QuickTime Pitfall)

| Test Sample MP4 | HEVC Video Tag | Expected Player Support (QuickTime / Safari) | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| ❌ [test_x265_hev1.mp4](videos/test_x265_hev1.mp4) | `hev1` | **Fails** to play on Safari/QuickTime (black screen / error) | `ffmpeg -i ... -c:v libx265 -tag:v hev1 ...` |
| 💚 [test_x265_hvc1.mp4](videos/test_x265_hvc1.mp4) | `hvc1` | **Plays perfectly** on all iOS/macOS Safari and QuickTime | `ffmpeg -i ... -c:v libx265 -tag:v hvc1 ...` |

## 2. Web Streaming Optimization (MP4 Fast Start / metadata Pitfall)

| Test Sample MP4 | Fast Start Enabled? | Expected Playback Behavior on Web Browsers | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| ❌ [test_x264_no_faststart.mp4](videos/test_x264_no_faststart.mp4) | No | **Lags/Buffers**: Browser must download the entire video before playing | `ffmpeg -i ... -c:v libx264 ...` |
| 💚 [test_x264_faststart.mp4](videos/test_x264_faststart.mp4) | **Yes** | **Instant Playback**: Video streams instantly while downloading in background | `ffmpeg -i ... -c:v libx264 -movflags +faststart ...` |

## 3. Chroma Subsampling & Color Depth Compatibility

| Test Sample MP4 | Subsampling / Depth | Expected Mobile HW Decoder Compatibility | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| 💚 [test_x264_yuv420p.mp4](videos/test_x264_yuv420p.mp4) | `yuv420p` (8-bit) | **Universal**: Flawless playback on all hardware decoders | `ffmpeg -i ... -pix_fmt yuv420p -c:v libx264` |
| ❌ [test_x264_yuv444p.mp4](videos/test_x264_yuv444p.mp4) | `yuv444p` (Lossless) | **Failures**: Crashes or fails on mobile hardware chips | `ffmpeg -i ... -pix_fmt yuv444p -c:v libx264` |
| ⚠️ [test_x265_10bit.mp4](videos/test_x265_10bit.mp4) | `yuv420p10le` (10-bit) | **Partial**: Supported on HDR chips, fails on legacy devices | `ffmpeg -i ... -pix_fmt yuv420p10le -c:v libx265` |

## 4. H.264 Profiles (Compression vs Compatibility)

| Test Sample MP4 | H.264 Profile | Compression Efficiency & compatibility | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| 💚 [test_x264_baseline.mp4](videos/test_x264_baseline.mp4) | `baseline` | **Low efficiency** but supports ancient legacy embedded devices | `ffmpeg -i ... -c:v libx264 -profile:v baseline` |
| 💚 [test_x264_high.mp4](videos/test_x264_high.mp4) | `high` | **Standard modern efficiency** for almost all web and desktop players | `ffmpeg -i ... -c:v libx264 -profile:v high` |

## 5. Audio Container Support (AAC inside MP4)

| Test Sample MP4 | Audio Codec | Expected Native iOS/macOS Player Support | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| 💚 [test_audio_aac.mp4](videos/test_audio_aac.mp4) | `aac` (AAC-LC) | **Universal**: Flawless audio playback on all players/devices | `ffmpeg -i ... -c:v libx264 -c:a aac` |

EOF

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

echo "=== 5. 生成虚拟源测试专属网页 virtual-sources.html ==="
TMP_VSRC_MD=$(mktemp /tmp/ffmpeg_vsrc_md.XXXXXX)

cat << 'EOF' > "$TMP_VSRC_MD"
# 🌈 FFmpeg Virtual Test Sources Showcase (macOS arm64)

[← Back to Feature Evolution Matrix](index.html)

This dedicated page showcases all the built-in virtual test video and audio sources compiled within our custom-built **FFmpeg 8-bin**. These source filters can be loaded dynamically via the `lavfi` input device to generate colors, shapes, noise, charts, and mathematical patterns without needing external files!

---

## 1. Standard Patterns & Grids

### 💚 Standard Color Bars & Timing (`testsrc`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "testsrc=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_testsrc.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_testsrc.mp4"></video>

### 💚 Modern Test Pattern (`testsrc2`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "testsrc2=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_testsrc2.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_testsrc2.mp4"></video>

---

## 2. Advanced Mathematical & Algorithmic Patterns

### 🌀 Mandelbrot Fractal Zoom (`mandelbrot`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "mandelbrot=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_mandelbrot.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_mandelbrot.mp4"></video>

### 🎨 Linear Gradient Dynamic Colors (`gradients`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "gradients=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_gradients.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_gradients.mp4"></video>

---

## 3. Analysis & Color Space Calibration

### 📊 YUV Color Space Reference (`yuvtestsrc`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "yuvtestsrc=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_yuvtestsrc.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_yuvtestsrc.mp4"></video>

### 📊 RGB Color Space Reference (`rgbtestsrc`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "rgbtestsrc=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_rgbtestsrc.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_rgbtestsrc.mp4"></video>

### 🎨 24-Color Reference Color Chart (`colorchart`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "colorchart=duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_colorchart.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_colorchart.mp4"></video>

---

## 4. Solid Colors & Audio Generation

### 💚 Solid Color Reference Background (`color`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "color=color=0x1a823b:duration=5:size=640x360:rate=30" -pix_fmt yuv420p -c:v libx264 vsrc_color.mp4`
* **Visual Demo**:
  <video width="640" height="360" controls muted loop src="videos/vsrc_color.mp4"></video>

### 🔊 1000Hz Sine Tone Waveform (`sine`)
* **FFmpeg Command**: `ffmpeg -f lavfi -i "color=color=darkblue:duration=5:size=640x360:rate=30" -f lavfi -i "sine=frequency=1000:duration=5" -pix_fmt yuv420p -c:v libx264 -c:a aac vsrc_sine.mp4`
* **Visual Demo (With Audio)**:
  <video width="640" height="360" controls loop src="videos/vsrc_sine.mp4"></video>
EOF

VSRC_MD_CONTENT=$(cat "$TMP_VSRC_MD")

cat << EOF > "$OUTPUT_DIR/virtual-sources.html"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>FFmpeg Virtual Test Sources Showcase</title>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
$(cat ./tools/GitHub-2025.css)

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
        .markdown-body video {
            max-width: 100%;
            border-radius: 6px;
            border: 1px solid var(--color-border-default, #d0d7de);
            box-shadow: 0 3px 12px rgba(0,0,0,0.08);
            margin: 10px 0;
        }
    </style>
</head>
<body class="markdown-body">

    <article id="content">
        </article>

    <script type="text/markdown" id="markdown-source">
${VSRC_MD_CONTENT}
    </script>

    <script>
        const src = document.getElementById('markdown-source').innerHTML;
        document.getElementById('content').innerHTML = marked.parse(src);
    </script>
</body>
</html>
EOF

rm -f "$TMP_VSRC_MD"
rm -f "$TMP_MD_DATA"
echo "🎉 融合 GitHub-2025.css 成功！原生网页与专属虚拟源测试页已生成至 ./$OUTPUT_DIR/ 目录。"