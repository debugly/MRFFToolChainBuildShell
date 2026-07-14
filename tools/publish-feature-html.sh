#!/bin/bash
set -e

echo "=== 1. 初始化并配置各个 FFmpeg 版本 ==="
./main.sh init -p macos -l 'ffmpeg4 ffmpeg5 ffmpeg6 ffmpeg7 ffmpeg8' -a arm64

echo "=== 2. 创建发布目录 ==="
OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"
touch "$OUTPUT_DIR/.nojekyll"

echo "=== 3. 生成 Feature Evolution Matrix Markdown 数据 ==="
TMP_MATRIX_MD=$(mktemp /tmp/ffmpeg_matrix.XXXXXX)

cat << 'EOF' > "$TMP_MATRIX_MD"
# FFmpeg Feature Evolution Matrix (macOS arm64)

[← Back to Portal](index.html)

> [!NOTE]
> This page is automatically generated. It compares the availability of protocols, codecs, filters, and other features across different FFmpeg versions.
> **Columns from left to right:** Newest (8.1.2) to Oldest (4.0.5). Blanks on the right indicate newly added features in that version.
EOF

./tools/list-all-feature.sh >> "$TMP_MATRIX_MD"

echo "=== 4. 生成 Player Compatibility Markdown 数据 ==="
TMP_COMPAT_MD=$(mktemp /tmp/ffmpeg_compat.XXXXXX)

cat << 'EOF' > "$TMP_COMPAT_MD"
# 🎬 Player Compatibility & Encoding Pitfalls Validation Suite

[← Back to Portal](index.html)

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

echo "=== 5. 生成 Virtual Test Sources Markdown 数据 ==="
TMP_VSRC_MD=$(mktemp /tmp/ffmpeg_vsrc_md.XXXXXX)

cat << 'EOF' > "$TMP_VSRC_MD"
# 🌈 FFmpeg Virtual Test Sources Showcase (macOS arm64)

[← Back to Portal](index.html)

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


echo "=== 6. 生成 Feature Evolution Matrix 网页 (feature-matrix.html) ==="
MATRIX_MD_CONTENT=$(cat "$TMP_MATRIX_MD")
cat << EOF > "$OUTPUT_DIR/feature-matrix.html"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>FFmpeg Feature Evolution Matrix</title>
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
    </style>
</head>
<body class="markdown-body">

    <article id="content">
        </article>

    <script type="text/markdown" id="markdown-source">
${MATRIX_MD_CONTENT}
    </script>

    <script>
        const src = document.getElementById('markdown-source').innerHTML;
        const container = document.getElementById('content');
        container.innerHTML = marked.parse(src);

        // 渲染 GitHub-style 警告框 (Alerts)
        container.querySelectorAll('blockquote').forEach(bq => {
            const text = bq.textContent.trim();
            const match = text.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i);
            if (match) {
                const type = match[1].toUpperCase();
                bq.className = 'markdown-alert markdown-alert-' + type.toLowerCase();
                
                const titleText = type.charAt(0) + type.slice(1).toLowerCase();
                let iconSvg = '';
                if (type === 'NOTE') {
                    iconSvg = '<svg class="octicon octicon-info" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>';
                } else if (type === 'TIP') {
                    iconSvg = '<svg class="octicon octicon-light-bulb" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M8 1.5c-2.363 0-4 1.832-4 4 0 1.053.383 1.896.9 2.525.503.613.9 1.157.9 2.225a.75.75 0 0 0 .75.75h3a.75.75 0 0 0 .75-.75c0-1.068.397-1.612.9-2.225.517-.629.9-1.472.9-2.525 0-2.168-1.637-4-4-4Zm0 11.5c-.822 0-1.5.618-1.5 1.5A1.5 1.5 0 0 0 8 16c.822 0 1.5-.618 1.5-1.5A1.5 1.5 0 0 0 8 13Z"></path></svg>';
                } else if (type === 'IMPORTANT') {
                    iconSvg = '<svg class="octicon octicon-report" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v10.5A1.75 1.75 0 0 1 14.25 14H8.75L5 15.75V14H1.75A1.75 1.75 0 0 1 0 12.25Zm1.75-.25a.25.25 0 0 0-.25.25v10.5c0 .138.112.25.25.25h3.75a.75.75 0 0 1 .75.75v1.07l2.28-1.07a.75.75 0 0 1 .47-.16h5.3a.25.25 0 0 0 .25-.25V1.75a.25.25 0 0 0-.25-.25ZM9 9H7V5h2Zm0 2.25h-2v-1.5h2Z"></path></svg>';
                } else if (type === 'WARNING') {
                    iconSvg = '<svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M6.457 1.047c.66-1.125 2.426-1.125 3.086 0l6.03 10.273c.63 1.074-.143 2.43-1.543 2.43H1.97c-1.4 0-2.173-1.356-1.543-2.43L6.457 1.047ZM9 5H7v4h2V5Zm0 5.25H7v1.5h2v-1.5Z"></path></svg>';
                } else if (type === 'CAUTION') {
                    iconSvg = '<svg class="octicon octicon-stop" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6c0 .199-.079.389-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5H5.31ZM8 4a1 1 0 1 1 0 2 1 1 0 0 1 0-2Zm1 5H7v4h2V9Z"></path></svg>';
                }
                
                const titleHtml = '<p class="markdown-alert-title">' + iconSvg + titleText + '</p>';
                let html = bq.innerHTML;
                html = html.replace(/\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](\s*<br\s*\/?>)?\s*/i, '');
                bq.innerHTML = titleHtml + html;
            }
        });
    </script>
</body>
</html>
EOF

echo "=== 7. 生成 Player Compatibility 网页 (player-compatibility.html) ==="
COMPAT_MD_CONTENT=$(cat "$TMP_COMPAT_MD")
cat << EOF > "$OUTPUT_DIR/player-compatibility.html"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Player Compatibility Pitfalls</title>
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
    </style>
</head>
<body class="markdown-body">

    <article id="content">
        </article>

    <script type="text/markdown" id="markdown-source">
${COMPAT_MD_CONTENT}
    </script>

    <script>
        const src = document.getElementById('markdown-source').innerHTML;
        const container = document.getElementById('content');
        container.innerHTML = marked.parse(src);

        // 渲染 GitHub-style 警告框 (Alerts)
        container.querySelectorAll('blockquote').forEach(bq => {
            const text = bq.textContent.trim();
            const match = text.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i);
            if (match) {
                const type = match[1].toUpperCase();
                bq.className = 'markdown-alert markdown-alert-' + type.toLowerCase();
                
                const titleText = type.charAt(0) + type.slice(1).toLowerCase();
                let iconSvg = '';
                if (type === 'NOTE') {
                    iconSvg = '<svg class="octicon octicon-info" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>';
                } else if (type === 'TIP') {
                    iconSvg = '<svg class="octicon octicon-light-bulb" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M8 1.5c-2.363 0-4 1.832-4 4 0 1.053.383 1.896.9 2.525.503.613.9 1.157.9 2.225a.75.75 0 0 0 .75.75h3a.75.75 0 0 0 .75-.75c0-1.068.397-1.612.9-2.225.517-.629.9-1.472.9-2.525 0-2.168-1.637-4-4-4Zm0 11.5c-.822 0-1.5.618-1.5 1.5A1.5 1.5 0 0 0 8 16c.822 0 1.5-.618 1.5-1.5A1.5 1.5 0 0 0 8 13Z"></path></svg>';
                } else if (type === 'IMPORTANT') {
                    iconSvg = '<svg class="octicon octicon-report" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v10.5A1.75 1.75 0 0 1 14.25 14H8.75L5 15.75V14H1.75A1.75 1.75 0 0 1 0 12.25Zm1.75-.25a.25.25 0 0 0-.25.25v10.5c0 .138.112.25.25.25h3.75a.75.75 0 0 1 .75.75v1.07l2.28-1.07a.75.75 0 0 1 .47-.16h5.3a.25.25 0 0 0 .25-.25V1.75a.25.25 0 0 0-.25-.25ZM9 9H7V5h2Zm0 2.25h-2v-1.5h2Z"></path></svg>';
                } else if (type === 'WARNING') {
                    iconSvg = '<svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M6.457 1.047c.66-1.125 2.426-1.125 3.086 0l6.03 10.273c.63 1.074-.143 2.43-1.543 2.43H1.97c-1.4 0-2.173-1.356-1.543-2.43L6.457 1.047ZM9 5H7v4h2V5Zm0 5.25H7v1.5h2v-1.5Z"></path></svg>';
                } else if (type === 'CAUTION') {
                    iconSvg = '<svg class="octicon octicon-stop" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6c0 .199-.079.389-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5H5.31ZM8 4a1 1 0 1 1 0 2 1 1 0 0 1 0-2Zm1 5H7v4h2V9Z"></path></svg>';
                }
                
                const titleHtml = '<p class="markdown-alert-title">' + iconSvg + titleText + '</p>';
                let html = bq.innerHTML;
                html = html.replace(/\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](\s*<br\s*\/?>)?\s*/i, '');
                bq.innerHTML = titleHtml + html;
            }
        });
    </script>
</body>
</html>
EOF

echo "=== 8. 生成 Virtual Test Sources 网页 (virtual-sources.html) ==="
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
        const container = document.getElementById('content');
        container.innerHTML = marked.parse(src);

        // 渲染 GitHub-style 警告框 (Alerts)
        container.querySelectorAll('blockquote').forEach(bq => {
            const text = bq.textContent.trim();
            const match = text.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i);
            if (match) {
                const type = match[1].toUpperCase();
                bq.className = 'markdown-alert markdown-alert-' + type.toLowerCase();
                
                const titleText = type.charAt(0) + type.slice(1).toLowerCase();
                let iconSvg = '';
                if (type === 'NOTE') {
                    iconSvg = '<svg class="octicon octicon-info" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>';
                } else if (type === 'TIP') {
                    iconSvg = '<svg class="octicon octicon-light-bulb" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M8 1.5c-2.363 0-4 1.832-4 4 0 1.053.383 1.896.9 2.525.503.613.9 1.157.9 2.225a.75.75 0 0 0 .75.75h3a.75.75 0 0 0 .75-.75c0-1.068.397-1.612.9-2.225.517-.629.9-1.472.9-2.525 0-2.168-1.637-4-4-4Zm0 11.5c-.822 0-1.5.618-1.5 1.5A1.5 1.5 0 0 0 8 16c.822 0 1.5-.618 1.5-1.5A1.5 1.5 0 0 0 8 13Z"></path></svg>';
                } else if (type === 'IMPORTANT') {
                    iconSvg = '<svg class="octicon octicon-report" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v10.5A1.75 1.75 0 0 1 14.25 14H8.75L5 15.75V14H1.75A1.75 1.75 0 0 1 0 12.25Zm1.75-.25a.25.25 0 0 0-.25.25v10.5c0 .138.112.25.25.25h3.75a.75.75 0 0 1 .75.75v1.07l2.28-1.07a.75.75 0 0 1 .47-.16h5.3a.25.25 0 0 0 .25-.25V1.75a.25.25 0 0 0-.25-.25ZM9 9H7V5h2Zm0 2.25h-2v-1.5h2Z"></path></svg>';
                } else if (type === 'WARNING') {
                    iconSvg = '<svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M6.457 1.047c.66-1.125 2.426-1.125 3.086 0l6.03 10.273c.63 1.074-.143 2.43-1.543 2.43H1.97c-1.4 0-2.173-1.356-1.543-2.43L6.457 1.047ZM9 5H7v4h2V5Zm0 5.25H7v1.5h2v-1.5Z"></path></svg>';
                } else if (type === 'CAUTION') {
                    iconSvg = '<svg class="octicon octicon-stop" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true" fill="currentColor" style="margin-right: 8px; display: inline-block; vertical-align: text-bottom;"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6c0 .199-.079.389-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5H5.31ZM8 4a1 1 0 1 1 0 2 1 1 0 0 1 0-2Zm1 5H7v4h2V9Z"></path></svg>';
                }
                
                const titleHtml = '<p class="markdown-alert-title">' + iconSvg + titleText + '</p>';
                let html = bq.innerHTML;
                html = html.replace(/\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](\s*<br\s*\/?>)?\s*/i, '');
                bq.innerHTML = titleHtml + html;
            }
        });
    </script>
</body>
</html>
EOF


echo "=== 9. 生成高级、现代化的 Portal 主页 (index.html) ==="
cat << 'EOF' > "$OUTPUT_DIR/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MR FFmpeg Toolchain Diagnostics Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0b0f19;
            --card-bg: rgba(22, 28, 45, 0.45);
            --card-border: rgba(255, 255, 255, 0.08);
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --color-blue: #3b82f6;
            --color-emerald: #10b981;
            --color-purple: #8b5cf6;
            --color-amber: #f59e0b;
            --transition-smooth: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html, body {
            overflow-x: hidden;
            width: 100%;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }

        /* Ambient Glowing Backgrounds */
        body::before {
            content: '';
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.15) 0%, transparent 70%);
            top: -100px;
            left: -100px;
            z-index: 0;
            pointer-events: none;
            filter: blur(40px);
            animation: floatGlow 15s infinite alternate ease-in-out;
        }

        body::after {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(139, 92, 246, 0.12) 0%, transparent 70%);
            bottom: -150px;
            right: -100px;
            z-index: 0;
            pointer-events: none;
            filter: blur(50px);
            animation: floatGlowAlt 20s infinite alternate ease-in-out;
        }

        @keyframes floatGlow {
            0% { transform: translate(0, 0) scale(1); }
            100% { transform: translate(100px, 50px) scale(1.1); }
        }

        @keyframes floatGlowAlt {
            0% { transform: translate(0, 0) scale(1.1); }
            100% { transform: translate(-120px, -50px) scale(0.9); }
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 80px 24px;
            z-index: 10;
            position: relative;
            width: 100%;
        }

        header {
            text-align: center;
            margin-bottom: 70px;
        }

        .logo-container {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 72px;
            height: 72px;
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.2) 0%, rgba(139, 92, 246, 0.2) 100%);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            margin-bottom: 24px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(10px);
        }

        .logo-container svg {
            width: 36px;
            height: 36px;
        }

        h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 3rem;
            font-weight: 800;
            line-height: 1.2;
            letter-spacing: -0.02em;
            margin-bottom: 16px;
            background: linear-gradient(to right, #ffffff 30%, #a5b4fc 70%, #6366f1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .subtitle {
            color: var(--text-secondary);
            font-size: 1.125rem;
            max-width: 650px;
            margin: 0 auto 32px;
            line-height: 1.6;
        }

        /* Dashboard Overview */
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(220px, 100%), 1fr));
            gap: 20px;
            margin-bottom: 50px;
        }

        .dash-item {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 20px;
            backdrop-filter: blur(12px);
            display: flex;
            flex-direction: column;
            gap: 8px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            transition: var(--transition-smooth);
        }
        
        .dash-item:hover {
            border-color: rgba(255, 255, 255, 0.15);
            transform: translateY(-2px);
        }

        .dash-label {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--text-secondary);
            font-weight: 500;
        }

        .dash-value {
            font-family: 'Outfit', sans-serif;
            font-size: 1.8rem;
            font-weight: 700;
            color: #ffffff;
        }

        /* Card Grid for Portal Links */
        .portal-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(320px, 100%), 1fr));
            gap: 30px;
            width: 100%;
        }

        .portal-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 24px;
            padding: 35px;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 320px;
            backdrop-filter: blur(12px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            transition: var(--transition-smooth);
            position: relative;
            overflow: hidden;
        }

        .portal-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            transition: var(--transition-smooth);
        }

        /* Blue Theme */
        .card-blue::before { background: linear-gradient(90deg, var(--color-blue), #60a5fa); }
        .card-blue:hover {
            border-color: rgba(59, 130, 246, 0.3);
            box-shadow: 0 15px 40px rgba(59, 130, 246, 0.15);
        }
        .card-blue:hover .card-icon {
            background: rgba(59, 130, 246, 0.2);
            color: #60a5fa;
        }

        /* Emerald Theme */
        .card-emerald::before { background: linear-gradient(90deg, var(--color-emerald), #34d399); }
        .card-emerald:hover {
            border-color: rgba(16, 185, 129, 0.3);
            box-shadow: 0 15px 40px rgba(16, 185, 129, 0.15);
        }
        .card-emerald:hover .card-icon {
            background: rgba(16, 185, 129, 0.2);
            color: #34d399;
        }

        /* Purple Theme */
        .card-purple::before { background: linear-gradient(90deg, var(--color-purple), #a78bfa); }
        .card-purple:hover {
            border-color: rgba(139, 92, 246, 0.3);
            box-shadow: 0 15px 40px rgba(139, 92, 246, 0.15);
        }
        .card-purple:hover .card-icon {
            background: rgba(139, 92, 246, 0.2);
            color: #a78bfa;
        }

        .card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .card-icon {
            width: 54px;
            height: 54px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.03);
            color: var(--text-secondary);
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: var(--transition-smooth);
        }

        .card-icon svg {
            width: 24px;
            height: 24px;
            fill: currentColor;
        }

        .card-badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 6px 12px;
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-secondary);
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .badge-active {
            background: rgba(16, 185, 129, 0.1);
            color: #34d399;
            border-color: rgba(16, 185, 129, 0.15);
        }

        .card-title {
            font-family: 'Outfit', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 12px;
            letter-spacing: -0.01em;
        }

        .card-desc {
            color: var(--text-secondary);
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .card-footer {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
            font-size: 0.95rem;
            color: #ffffff;
            margin-top: auto;
        }

        .card-footer svg {
            width: 18px;
            height: 18px;
            fill: currentColor;
            transition: transform 0.3s ease;
        }

        .portal-card:hover .card-footer svg {
            transform: translateX(6px);
        }

        .portal-card:hover {
            transform: translateY(-6px);
        }

        footer {
            text-align: center;
            padding: 40px 24px;
            color: #4b5563;
            font-size: 0.85rem;
            border-top: 1px solid rgba(255, 255, 255, 0.03);
            z-index: 10;
            position: relative;
            margin-top: 60px;
        }

        @media (max-width: 768px) {
            h1 { font-size: 2.2rem; }
            .container { padding: 40px 16px; }
            .portal-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <div class="container">
        <header>
            <div class="logo-container">
                <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M19 12c0-.5-.2-.9-.5-1.2L6.7 4.2c-.4-.3-1-.3-1.4.1C5.1 4.5 5 4.9 5 5.3v13.4c0 .4.1.8.3 1 .4.4 1 .4 1.4.1l11.8-6.6c.3-.3.5-.7.5-1.2z" fill="url(#playGrad)"/>
                    <defs>
                        <linearGradient id="playGrad" x1="5" y1="5" x2="19" y2="19" gradientUnits="userSpaceOnUse">
                            <stop offset="0%" stop-color="#3b82f6" />
                            <stop offset="100%" stop-color="#8b5cf6" />
                        </linearGradient>
                    </defs>
                </svg>
            </div>
            <h1>MR FFmpeg Diagnostics Portal</h1>
            <p class="subtitle">An advanced environment-diagnostics, pitfall validation, and feature cross-reference cockpit for our custom Apple Silicon & Android built-in FFmpeg Toolchains.</p>
        </header>

        <div class="dashboard-grid">
            <div class="dash-item">
                <span class="dash-label">Target Architecture</span>
                <span class="dash-value" style="color: var(--color-blue);">macOS arm64</span>
            </div>
            <div class="dash-item">
                <span class="dash-label">Tracked Toolchains</span>
                <span class="dash-value" style="color: var(--color-purple);">5 Versions</span>
            </div>
            <div class="dash-item">
                <span class="dash-label">Diagnostic Checks</span>
                <span class="dash-value" style="color: var(--color-emerald);">2,500+ Nodes</span>
            </div>
            <div class="dash-item">
                <span class="dash-label">Validation Assets</span>
                <span class="dash-value" style="color: var(--color-amber);">13 Modules</span>
            </div>
        </div>

        <div class="portal-grid">
            <!-- Card 1: Feature Matrix -->
            <a href="feature-matrix.html" class="portal-card card-blue">
                <div class="card-top">
                    <div class="card-icon">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M4 11h5V5H4v6zm0 7h5v-6H4v6zm6 0h5v-6h-5v6zm6 0h5v-6h-5v6zm-6-7h5V5h-5v6zm6-6v6h5V5h-5z"/>
                        </svg>
                    </div>
                    <span class="card-badge badge-active">Dynamic</span>
                </div>
                <div>
                    <h2 class="card-title">Feature Evolution Matrix</h2>
                    <p class="card-desc">Compare compiled protocol support, hardware filters, container formats, and features seamlessly across FFmpeg 4.x, 5.x, 6.x, 7.x and 8.x.</p>
                </div>
                <div class="card-footer" style="color: #60a5fa;">
                    Explore Evolution Matrix
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                </div>
            </a>

            <!-- Card 2: Compatibility Suite -->
            <a href="player-compatibility.html" class="portal-card card-emerald">
                <div class="card-top">
                    <div class="card-icon">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M17 1.01L7 1c-1.1 0-2 .9-2 2v18c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V3c0-1.1-.9-1.99-2-1.99zM17 19H7V5h10v14z"/>
                        </svg>
                    </div>
                    <span class="card-badge badge-active">Test Suite</span>
                </div>
                <div>
                    <h2 class="card-title">Player Compatibility Pitfalls</h2>
                    <p class="card-desc">Diagnose video container pitfalls, HEVC hvc1/hev1 tags, web fast-start streaming, chroma subsampling limits, and Apple iOS/Safari player traps.</p>
                </div>
                <div class="card-footer" style="color: #34d399;">
                    Verify Player Pitfalls
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                </div>
            </a>

            <!-- Card 3: Virtual Sources -->
            <a href="virtual-sources.html" class="portal-card card-purple">
                <div class="card-top">
                    <div class="card-icon">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
                        </svg>
                    </div>
                    <span class="card-badge badge-active">Live Demos</span>
                </div>
                <div>
                    <h2 class="card-title">Virtual Test Sources</h2>
                    <p class="card-desc">Showcase procedural video/audio generators (Mandelbrot fractals, color charts, sine sweeps, moving patterns) with high-fidelity pre-compiled demo clips.</p>
                </div>
                <div class="card-footer" style="color: #a78bfa;">
                    Open Virtual Sources
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                </div>
            </a>
        </div>
    </div>

    <footer>
        &copy; 2026 MRFFToolChain Diagnostics Cockpit. All rights reserved. Built dynamically with Vanilla Web Tech.
    </footer>

</body>
</html>
EOF

rm -f "$TMP_MATRIX_MD"
rm -f "$TMP_COMPAT_MD"
rm -f "$TMP_VSRC_MD"

echo "🎉 融合 GitHub-2025.css 成功！原生网页、专用功能矩阵页、播放器兼容性页与专属虚拟源测试页已生成至 ./$OUTPUT_DIR/ 目录。"