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
DURATION=${1:-15}
# Output directory (default to build/docs/videos relative to the workspace root)
OUTPUT_DIR=${2:-./build/docs/videos}

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
# PITFALL 6: Interlaced Video Generation (tinterlace / comb video)
# ---------------------------------------------------------------------
echo -e "\033[34m[*] Case 6.1: Generating Interlaced Video (interleave_top)...\033[0m"
"$FFMPEG_BIN" -f lavfi -i "testsrc2=size=1280x720:rate=50" \
    -vf "tinterlace=mode=interleave_top" \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -t "${DURATION}" \
    -y "$OUTPUT_DIR/test_comb.mp4"

# ---------------------------------------------------------------------
# PITFALL 7: Transparent Background Video (alpha channel)
# ---------------------------------------------------------------------
# The VP9 alpha WebM sample is generated here, not committed as a binary.
# $FFMPEG_BIN (the toolchain build) has no libvpx in its dependency set,
# so this alpha case will
# pick the first ffmpeg on the machine that really provides the encoder (Homebrew ffmpeg
# in CI -- see .github/workflows/generate portal website.yaml). Generating instead of
# shipping binaries keeps the samples reproducible and in sync with the documented commands.
#
# Do NOT use the 'drawbox' filter on a fully transparent canvas -- it blends against
# alpha=0 and silently yields an all-transparent (empty) video.
# Composite an opaque shape onto the transparent base with 'overlay' instead.

# echo the first ffmpeg (toolchain build, then the system one) providing $1 as encoder
ffmpeg_with_encoder() {
    local encoder=$1 candidate
    for candidate in "$FFMPEG_BIN" "$(command -v ffmpeg 2>/dev/null)" /opt/homebrew/bin/ffmpeg /usr/local/bin/ffmpeg; do
        [[ -n "$candidate" && -x "$candidate" ]] || continue
        if "$candidate" -hide_banner -encoders 2>/dev/null | awk '{print $2}' | grep -qx "$encoder"; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

# Move edge to edge and back every 5 seconds, keeping the whole square visible.
FFMPEG_VP9=$(ffmpeg_with_encoder libvpx-vp9 || true)
if [[ -n "$FFMPEG_VP9" ]]; then
    echo -e "\033[34m[*] Case 7.1: Generating Transparent WebM (VP9 yuva420p, alpha channel)...\033[0m"
    "$FFMPEG_VP9" -f lavfi -i "color=c=black@0.0:s=640x480:rate=30,format=yuva420p" \
        -f lavfi -i "color=c=red:s=80x80:rate=30,format=yuva420p" \
        -filter_complex "[0][1]overlay=x='(W-w)*(1-cos(2*PI*t/5))/2':y=200:format=auto" \
        -c:v libvpx-vp9 \
        -pix_fmt yuva420p \
        -auto-alt-ref 0 \
        -t "${DURATION}" \
        -y "$OUTPUT_DIR/test_transparent.webm"
else
    echo -e "\033[33m[!] Skipping Case 7.1 (Transparent WebM): no ffmpeg with the libvpx-vp9 encoder found.\033[0m"
fi

# ---------------------------------------------------------------------
# VIRTUAL SOURCES: Generate showcase videos for virtual test sources
# ---------------------------------------------------------------------
echo "=========================================================="
echo -e "\033[35m[*] Section 6: Generating Virtual Sources Showcase Videos...\033[0m"
echo "=========================================================="

echo -e "\033[34m[*] Generating Showcase: testsrc (Color bars + timing)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "testsrc=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_testsrc.mp4"

echo -e "\033[34m[*] Generating Showcase: testsrc2 (Modern color bars)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "testsrc2=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_testsrc2.mp4"

echo -e "\033[34m[*] Generating Showcase: mandelbrot (Mandelbrot fractal zoom)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "mandelbrot=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_mandelbrot.mp4"

echo -e "\033[34m[*] Generating Showcase: gradients (Linear gradient dynamic colors)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "gradients=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_gradients.mp4"

echo -e "\033[34m[*] Generating Showcase: yuvtestsrc (YUV space analysis)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "yuvtestsrc=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_yuvtestsrc.mp4"

echo -e "\033[34m[*] Generating Showcase: rgbtestsrc (RGB space analysis)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "rgbtestsrc=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_rgbtestsrc.mp4"

echo -e "\033[34m[*] Generating Showcase: colorchart (24-color reference chart)...\033[0m"
"$FFMPEG_BIN" -t "${DURATION}" -f lavfi -i "colorchart=rate=30,scale=640:360" \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -y "$OUTPUT_DIR/vsrc_colorchart.mp4"

# ---------------------------------------------------------------------
# REFERENCE TEST CARDS: colour chart, SMPTE bars, banding ramp, frame counter
# ---------------------------------------------------------------------
# Calibration material for a display, TV, capture card or player. Everything
# is drawn with filters, so no assets ship with the repo.
#
# Frame numbers need the drawtext filter, which depends on an optional
# build-time dependency (freetype) -- the toolchain build may not have it.
# Probe for the filter and fall back to a pure-filter bit counter: eight
# boxes show the frame number in binary (LSB left), a white square flashes
# on every new second.
CARD_W=${CARD_W:-1920}
CARD_H=${CARD_H:-1080}
CARD_FPS=${CARD_FPS:-30}
CARD_DURATION=${CARD_DURATION:-$DURATION}

echo "=========================================================="
echo -e "\033[35m[*] Section 7: Generating Reference Test Cards...\033[0m"
echo "=========================================================="

# echo the first ffmpeg (toolchain build, then the system one) providing $1 as filter
ffmpeg_with_filter() {
    local filter=$1 candidate
    for candidate in "$FFMPEG_BIN" "$(command -v ffmpeg 2>/dev/null)" /opt/homebrew/bin/ffmpeg /usr/local/bin/ffmpeg; do
        [[ -n "$candidate" && -x "$candidate" ]] || continue
        if "$candidate" -hide_banner -filters 2>/dev/null | awk '{print $2}' | grep -qx "$filter"; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

# 8 x 6 patch matrix, left to right / top to bottom:
#   primaries, 75 % bars, grayscale ladder, skin tones, saturated ramps, IRE steps
CHART_PATCHES=(
    ffffff ffff00 00ffff 00ff00 ff00ff ff0000 0000ff 000000
    bfbf00 00bfbf 00bf00 bf00bf bf0000 0000bf 101010 ebebeb
    e6e6e6 cccccc b3b3b3 999999 808080 666666 4d4d4d 333333
    f2cdb2 e0ac8a b27c5c 784e38 ff8000 8000ff 804020 008080
    ff4040 40ff40 4040ff ffff40 40ffff ff40ff 181818 f6f6f6
    000000 1a1a1a 333333 666666 999999 cccccc ffffff ffffff
)

# build_color_chart <output>
# Video only: the sync beep pass at the end of the script supplies the audio.
build_color_chart() {
    local out=$1
    local cols=8 rows=6
    local grid_h=$(( CARD_H * 5 / 6 ))
    local pw=$(( CARD_W / cols ))
    local ph=$(( grid_h / rows ))
    local strip_h=$(( CARD_H - grid_h ))
    local ramp_h=$(( strip_h * 7 / 10 ))
    local -a filters=() cmd=()
    local i c r v hex chain

    for i in "${!CHART_PATCHES[@]}"; do
        c=$(( i % cols )); r=$(( i / cols ))
        filters+=("drawbox=x=$(( c * pw )):y=$(( r * ph )):w=$pw:h=$ph:color=0x${CHART_PATCHES[$i]}:t=fill")
    done

    # 11-step grey strip under the continuous black->white ramp
    for i in 0 1 2 3 4 5 6 7 8 9 10; do
        v=$(( i * 255 / 10 )); hex=$(printf '%02x' "$v")
        filters+=("drawbox=x=$(( i * CARD_W / 11 )):y=$(( grid_h + ramp_h )):w=$(( CARD_W / 11 )):h=$(( strip_h - ramp_h )):color=0x${hex}${hex}${hex}:t=fill")
    done

    # overscan brackets at the four corners + centre cross.
    # Draw these last: a mark drawn earlier is overpainted by the patches.
    filters+=("drawbox=x=12:y=12:w=90:h=6:color=white:t=fill" "drawbox=x=12:y=12:w=6:h=90:color=white:t=fill")
    filters+=("drawbox=x=$(( CARD_W - 102 )):y=12:w=90:h=6:color=white:t=fill" "drawbox=x=$(( CARD_W - 18 )):y=12:w=6:h=90:color=white:t=fill")
    filters+=("drawbox=x=12:y=$(( CARD_H - 18 )):w=90:h=6:color=white:t=fill" "drawbox=x=12:y=$(( CARD_H - 102 )):w=6:h=90:color=white:t=fill")
    filters+=("drawbox=x=$(( CARD_W - 102 )):y=$(( CARD_H - 18 )):w=90:h=6:color=white:t=fill" "drawbox=x=$(( CARD_W - 18 )):y=$(( CARD_H - 102 )):w=6:h=90:color=white:t=fill")
    filters+=("drawbox=x=$(( CARD_W / 2 - 60 )):y=$(( CARD_H / 2 - 3 )):w=120:h=6:color=white:t=fill" "drawbox=x=$(( CARD_W / 2 - 3 )):y=$(( CARD_H / 2 - 60 )):w=6:h=120:color=white:t=fill")

    chain=$(IFS=,; echo "${filters[*]}")
    cmd=("$FFMPEG_BIN" -hide_banner -y
        -f lavfi -i "color=c=black:s=${CARD_W}x${CARD_H}:r=${CARD_FPS}"
        -f lavfi -i "gradients=s=${CARD_W}x${ramp_h}:r=${CARD_FPS}:c0=black:c1=white:x0=0:y0=0:x1=$(( CARD_W - 1 )):y1=0:type=linear")
    cmd+=(-filter_complex "[0:v]${chain}[patches];[patches][1:v]overlay=0:${grid_h}[cat];[cat]negate=enable='eq(mod(floor(t)\\,2)\\,1)'[out]" -map "[out]")
    cmd+=(-t "$CARD_DURATION" -c:v libx264 -crf 16 -pix_fmt yuv420p -movflags +faststart "$out")
    "${cmd[@]}"
}

# build_frame_counter <output>
# Same layout as the reference clip: a background tint that changes every
# second, a reference grid, the frame number, its timecode, a "frame N / last"
# readout and a progress bar that grows to full width.
#   frozen frame  -> number and tint stop advancing
#   dropped frame -> a number is skipped
#   bad seek      -> number and timecode disagree
build_frame_counter() {
    local out=$1 font="" candidate text_ffmpeg total chain
    local -a filters=() cmd=()
    local bit x x0 bw=110 gap=24
    local fps=60

    total=$(( CARD_DURATION * fps - 1 ))

    for candidate in /System/Library/Fonts/Supplemental/Arial.ttf \
                     /System/Library/Fonts/Supplemental/Helvetica.ttc \
                     /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf; do
        [[ -f "$candidate" ]] && { font=$candidate; break; }
    done
    text_ffmpeg=$(ffmpeg_with_filter drawtext || true)

    # shared chrome: per-second background tint + reference grid
    filters+=("drawbox=x=0:y=0:w=iw:h=ih:color=0x141a22:t=fill:enable='eq(mod(floor(t)\\,4)\\,0)'")
    filters+=("drawbox=x=0:y=0:w=iw:h=ih:color=0x22141a:t=fill:enable='eq(mod(floor(t)\\,4)\\,1)'")
    filters+=("drawbox=x=0:y=0:w=iw:h=ih:color=0x14221a:t=fill:enable='eq(mod(floor(t)\\,4)\\,2)'")
    filters+=("drawbox=x=0:y=0:w=iw:h=ih:color=0x1e1e14:t=fill:enable='eq(mod(floor(t)\\,4)\\,3)'")
    filters+=("drawgrid=width=60:height=120:thickness=1:color=0x262c34")

    if [[ -n "$text_ffmpeg" && -n "$font" ]]; then
        echo -e "\033[34m[*] Frame counter: numbered (drawtext, ${font##*/})...\033[0m"
        filters+=("drawtext=fontfile=${font}:text='%{n}':fontcolor=white:fontsize=300:x=(w-tw)/2:y=(h-th)/2")
        filters+=("drawtext=fontfile=${font}:text='%{pts\\:hms}':fontcolor=0xffdc3c:fontsize=72:x=(w-tw)/2:y=h-200")
        filters+=("drawtext=fontfile=${font}:text='60 fps  frame %{n} / ${total}':fontcolor=0x969696:fontsize=40:x=40:y=40")
        cmd=("$text_ffmpeg")
    else
        echo -e "\033[33m[!] No drawtext filter (or font) in any ffmpeg: frame counter shows the frame number in binary instead.\033[0m"
        x0=$(( (CARD_W - (8 * bw + 7 * gap)) / 2 ))
        for bit in 0 1 2 3 4 5 6 7; do
            x=$(( x0 + bit * (bw + gap) ))
            filters+=("drawbox=x=${x}:y=$(( CARD_H / 2 - bw / 2 )):w=${bw}:h=${bw}:color=0x30e060:t=fill:enable='eq(mod(floor(n/pow(2\\,${bit}))\\,2)\\,1)'")
        done
        cmd=("$FFMPEG_BIN")
    fi

    chain=$(IFS=,; echo "${filters[*]}")
    "${cmd[@]}" -hide_banner -y \
        -f lavfi -i "color=c=0x141414:s=${CARD_W}x${CARD_H}:r=${fps}" \
        -f lavfi -i "color=c=0xff3c3c:s=${CARD_W}x12:r=${fps}" \
        -t "$CARD_DURATION" \
        -filter_complex "[0:v]${chain}[base];[base][1:v]overlay=x='-overlay_w*(1-n/${total})':y=$(( CARD_H - 12 )):shortest=1[out]" \
        -map "[out]" -c:v libx264 -crf 18 -pix_fmt yuv420p -movflags +faststart "$out"
}

echo -e "\033[34m[*] Test card: colour chart, inverted every second (colour / contrast / frozen frame)...\033[0m"
build_color_chart "$OUTPUT_DIR/card_colorchart.mp4"

echo -e "\033[34m[*] Test card: SMPTE HD bars...\033[0m"
"$FFMPEG_BIN" -hide_banner -y -f lavfi -i "smptehdbars=size=${CARD_W}x${CARD_H}:rate=${CARD_FPS}" \
    -t "$CARD_DURATION" \
    -c:v libx264 -crf 16 -pix_fmt yuv420p \
    -y "$OUTPUT_DIR/card_smptebars.mp4"

echo -e "\033[34m[*] Test card: black->white ramp (banding / bit depth)...\033[0m"
"$FFMPEG_BIN" -hide_banner -y -f lavfi -i "gradients=s=${CARD_W}x${CARD_H}:r=${CARD_FPS}:c0=black:c1=white:x0=0:y0=0:x1=$(( CARD_W - 1 )):y1=0:type=linear" \
    -t "$CARD_DURATION" \
    -c:v libx264 -crf 16 -pix_fmt yuv420p \
    -y "$OUTPUT_DIR/card_ramp.mp4"

echo -e "\033[34m[*] Test card: frame counter 60 fps (dropped frames / stutter / seek)...\033[0m"
build_frame_counter "$OUTPUT_DIR/card_framecounter.mp4"

# ---------------------------------------------------------------------
# SYNC BEEP: one 1 kHz, 100 ms burst at the start of every second
# ---------------------------------------------------------------------
# Added as a second pass so every sample carries the same audio marker: the
# beep lands on each whole second of the picture, which makes it easy to hear
# (or measure) an A/V offset, and a missing/duplicated beep exposes dropped
# audio. 100 ms is short enough to leave the remaining 0.9 s silent.
BEEP_SRC="aevalsrc=0.125*sin(2*PI*1000*t)*if(lt(mod(t\,1)\,0.12)\,pow(sin(PI*mod(t\,1)/0.12)\,2)\,0):s=48000:c=stereo"

add_sync_beep() {
    local file=$1
    local tmp="${file%.*}.beep.${file##*.}"
    "$FFMPEG_BIN" -hide_banner -loglevel error -y -i "$file" -f lavfi -i "$BEEP_SRC" \
        -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 128k -shortest \
        -movflags +faststart "$tmp" && mv "$tmp" "$file"
}

echo -e "\033[34m[*] Muxing the per-second sync beep into every sample...\033[0m"
for clip in "$OUTPUT_DIR"/*.mp4; do
    [[ -f "$clip" ]] || continue
    add_sync_beep "$clip"
done

echo "=========================================================="
echo -e "\033[32m🎉 Success! All test videos generated successfully in $OUTPUT_DIR.\033[0m"
echo "=========================================================="
