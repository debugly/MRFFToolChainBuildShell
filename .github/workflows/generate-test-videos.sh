#!/usr/bin/env bash
#
# Copyright (C) 2026 Matt Reach <qianlongxu@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Robust automated video testing harness to generate various validation and compatibility pitfall videos.
#

set -e

# Duration parameter (default to 5 seconds for fast CI execution)
DURATION=${1:-5}
# Output directory (default to docs/videos relative to the workspace root)
OUTPUT_DIR=${2:-./docs/videos}

mkdir -p "$OUTPUT_DIR"

# Locate the compiled ffmpeg binary
FFMPEG_BIN=""
HOST_ARCH=$(uname -m)

# Candidates order of preference
CANDIDATES=(
    "build/product/macos/universal/ffmpeg/bin/ffmpeg-macos-${HOST_ARCH}"
    "build/product/macos/universal/ffmpeg/bin/ffmpeg-macos-arm64"
)

for path in "${CANDIDATES[@]}"; do
    if [[ -x "$path" ]]; then
        FFMPEG_BIN="$path"
        break
    fi
done

# Fallback to system installed ffmpeg if no custom compilation is found
if [[ -z "$FFMPEG_BIN" ]]; then
    if command -v ffmpeg >/dev/null 2>&1; then
        FFMPEG_BIN=$(command -v ffmpeg)
    fi
fi

if [[ -z "$FFMPEG_BIN" ]]; then
    echo "=========================================================="
    echo -e "\033[31m!! ERROR: Could not locate any FFmpeg executable.\033[0m"
    echo "=========================================================="
    exit 1
fi

echo "=========================================================="
echo -e "\033[32m[*] Using FFmpeg binary:\033[0m $FFMPEG_BIN"
echo -e "\033[32m[*] Output Duration:\033[0m ${DURATION} seconds"
echo -e "\033[32m[*] Output Directory:\033[0m ${OUTPUT_DIR}"
echo "=========================================================="
echo

# ---------------------------------------------------------------------
# PITFALL 1: H.265 Tagging (hev1 vs hvc1) - Safari/QuickTime Compatibility
# ---------------------------------------------------------------------
echo -e "\033[34m[*] Case 1.1: Generating HEVC with default 'hev1' tag (QuickTime fail)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx265 \
    -tag:v hev1 \
    -y "$OUTPUT_DIR/test_x265_hev1.mp4"

echo -e "\033[34m[*] Case 1.2: Generating HEVC with Apple-friendly 'hvc1' tag (QuickTime pass)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx265 \
    -tag:v hvc1 \
    -y "$OUTPUT_DIR/test_x265_hvc1.mp4"

# ---------------------------------------------------------------------
# PITFALL 2: Web Fast Start (moov atom position)
# ---------------------------------------------------------------------
echo -e "\033[34m[*] Case 2.1: Generating MP4 without faststart (Web player lags/buffers)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/test_x264_no_faststart.mp4"

echo -e "\033[34m[*] Case 2.2: Generating MP4 with faststart (Web player plays instantly)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -movflags +faststart \
    -y "$OUTPUT_DIR/test_x264_faststart.mp4"

# ---------------------------------------------------------------------
# PITFALL 3: Chroma Subsampling / Pixel Format (yuv420p vs yuv444p vs yuv420p10le)
# ---------------------------------------------------------------------
echo -e "\033[34m[*] Case 3.1: Generating standard yuv420p H.264 (Universally compatible)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/test_x264_yuv420p.mp4"

echo -e "\033[34m[*] Case 3.2: Generating yuv444p H.264 (Screen lossy, fails on mobile HW)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv444p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/test_x264_yuv444p.mp4"

echo -e "\033[34m[*] Case 3.3: Generating 10-bit yuv420p10le HEVC (High fidelity, fails on legacy decoders)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p10le \
    -c:v libx265 \
    -tag:v hvc1 \
    -y "$OUTPUT_DIR/test_x265_10bit.mp4"

# ---------------------------------------------------------------------
# PITFALL 4: H.264 Profile (Baseline vs High)
# ---------------------------------------------------------------------
echo -e "\033[34m[*] Case 4.1: Generating H.264 Baseline Profile (Ultra-legacy device compatible)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -profile:v baseline \
    -y "$OUTPUT_DIR/test_x264_baseline.mp4"

echo -e "\033[34m[*] Case 4.2: Generating H.264 High Profile (Modern standard efficiency)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -profile:v high \
    -y "$OUTPUT_DIR/test_x264_high.mp4"

# ---------------------------------------------------------------------
# PITFALL 5: Audio Format Container Pitfall (AAC vs Opus in MP4)
# ---------------------------------------------------------------------
echo -e "\033[34m[*] Case 5.1: Generating MP4 with standard AAC audio (Universally compatible)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
    -f lavfi -i "sine=frequency=1000:duration=${DURATION}" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -c:a aac \
    -y "$OUTPUT_DIR/test_audio_aac.mp4"

# echo -e "\033[34m[*] Case 5.2: Generating MP4 with Opus audio (Highly efficient, fails on older player/iOS)...\033[0m"
# "$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=320x240:rate=30" \
#     -f lavfi -i "sine=frequency=1000:duration=${DURATION}" \
#     -pix_fmt yuv420p \
#     -c:v libx264 \
#     -c:a libopus \
#     -y "$OUTPUT_DIR/test_audio_opus.mp4"

# ---------------------------------------------------------------------
# VIRTUAL SOURCES: Generate showcase videos for virtual test sources
# ---------------------------------------------------------------------
echo "=========================================================="
echo -e "\033[35m[*] Section 6: Generating Virtual Sources Showcase Videos...\033[0m"
echo "=========================================================="

echo -e "\033[34m[*] Generating Showcase: testsrc (Color bars + timing)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_testsrc.mp4"

echo -e "\033[34m[*] Generating Showcase: testsrc2 (Modern color bars)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc2=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_testsrc2.mp4"

echo -e "\033[34m[*] Generating Showcase: sine (1000Hz tone with static background)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "color=color=darkblue:duration=${DURATION}:size=640x360:rate=30" \
    -f lavfi -i "sine=frequency=1000:duration=${DURATION}" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -c:a aac \
    -y "$OUTPUT_DIR/vsrc_sine.mp4"

echo -e "\033[34m[*] Generating Showcase: color (Solid green background)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "color=color=0x1a823b:duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_color.mp4"

echo -e "\033[34m[*] Generating Showcase: mandelbrot (Mandelbrot fractal zoom)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "mandelbrot=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_mandelbrot.mp4"

echo -e "\033[34m[*] Generating Showcase: gradients (Linear gradient dynamic colors)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "gradients=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_gradients.mp4"

echo -e "\033[34m[*] Generating Showcase: yuvtestsrc (YUV space analysis)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "yuvtestsrc=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_yuvtestsrc.mp4"

echo -e "\033[34m[*] Generating Showcase: rgbtestsrc (RGB space analysis)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "rgbtestsrc=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_rgbtestsrc.mp4"

echo -e "\033[34m[*] Generating Showcase: colorchart (24-color reference chart)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "colorchart=duration=${DURATION}:size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_colorchart.mp4"

echo "=========================================================="
echo -e "\033[32m🎉 Success! All test videos generated successfully in $OUTPUT_DIR.\033[0m"
echo "=========================================================="
