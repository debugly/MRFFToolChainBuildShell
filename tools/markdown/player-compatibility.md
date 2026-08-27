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

## 6. Interlaced Video Generation (Comb Video)

| Test Sample MP4 | Filter Mode | Expected Player Behavior | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| ⚠️ [test_comb.mp4](videos/test_comb.mp4) | `interleave_top` | **Comb Effect**: Interlaced video (top field first), requires deinterlacing | `ffmpeg -f lavfi -i "testsrc2=size=1280x720:rate=50" -vf "tinterlace=mode=interleave_top" -c:v libx264 -pix_fmt yuv420p -t 10 -y test_comb.mp4` |

## 7. Transparent Background Video (Alpha Channel / VP9 WebM)

WebM with a VP9 alpha channel (`yuva420p`) lets video composite over a page background — no green-screen keying required. **Chrome & Firefox** render the transparency correctly; **Safari/QuickTime** have poor support for alpha WebM and may show a black/opaque background instead.

> [!WARNING]
> Do **not** use the `drawbox` filter to draw onto a fully transparent canvas — it blends against alpha=0 and silently produces an all-transparent (empty) video. Composite an opaque shape onto the transparent base with `overlay` instead, as shown below.

| Test Sample WebM | Pixel Format | Expected Player Behavior | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| 💚 [test_transparent.webm](videos/test_transparent.webm) | `yuva420p` | **Transparent**: background shows through on Chrome/Firefox; opaque on Safari | `ffmpeg -f lavfi -i "color=c=black@0.0:s=640x480:r=30:d=5,format=yuva420p" -f lavfi -i "color=c=red:s=80x80:r=30:d=5,format=yuva420p" -filter_complex "[0][1]overlay=x='100+t*80':y=200:format=auto" -c:v libvpx-vp9 -pix_fmt yuva420p -auto-alt-ref 0 test_transparent.webm` |

**Visual Demo** (checkerboard shows through the transparent regions):

<div style="display:inline-block;padding:10px;border-radius:8px;background-color:#808080;background-image:linear-gradient(45deg,#ccc 25%,transparent 25%),linear-gradient(-45deg,#ccc 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#ccc 75%),linear-gradient(-45deg,transparent 75%,#ccc 75%);background-size:24px 24px;background-position:0 0,0 12px,12px -12px,-12px 0;">
  <video width="640" height="480" autoplay loop muted playsinline src="videos/test_transparent.webm"></video>
</div>
