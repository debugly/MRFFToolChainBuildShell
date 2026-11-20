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

## 2. MP4 Metadata Placement (Tail `moov` and Fast Start)

| Test Sample MP4 | Top-Level Box Order | What It Tests | FFmpeg Command |
| :--- | :---: | :--- | :--- |
| [Tail `moov` MP4](videos/test_x264_no_faststart.mp4) | `mdat` → `moov` | The player must reach the metadata at the end, then read earlier media data. | `ffmpeg -i ... -c:v libx264 -movflags 0 ...` |
| [Fast-start control](videos/test_x264_faststart.mp4) | `moov` → `mdat` | The same H.264 stream with metadata available before the media data. | `ffmpeg -i test_x264_no_faststart.mp4 -c copy -movflags +faststart test_x264_faststart.mp4` |

For [FSPlayer issue #52](https://github.com/debugly/fsplayer/issues/52), serve the tail-`moov` sample over HTTP. Try a server that honors Range requests and one that ignores them. Check that the first frame plays, then seek forward and back.

Generate a video-only 15-second tail-`moov` sample locally with FFmpeg and libx264.

```sh
ffmpeg -f lavfi -i "testsrc2=duration=15:size=640x360:rate=30" \
  -pix_fmt yuv420p -c:v libx264 -preset fast -crf 16 -movflags 0 test_x264_no_faststart.mp4
```

For a local server that ignores Range, run `python3 -m http.server --bind 127.0.0.1 8000` from the sample directory. Open `http://127.0.0.1:8000/test_x264_no_faststart.mp4` in FSPlayer on the same machine.

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

## 7. Transparent Background Video (Alpha Channel)

Alpha video composites over the page background — no green-screen keying required. The **VP9 alpha WebM** sample (`yuva420p`) tests transparency in Chrome and Firefox; Safari/QuickTime may display an opaque background.

> [!WARNING]
> Do **not** use the `drawbox` filter to draw onto a fully transparent canvas — it blends against alpha=0 and silently produces an all-transparent (empty) video. Composite an opaque shape onto the transparent base with `overlay` instead, as shown below.

| Test Sample | Pixel Format | Expected Player Behavior | FFmpeg Encoding Command |
| :--- | :---: | :--- | :--- |
| 💚 [test_transparent.webm](videos/test_transparent.webm) | `yuva420p` | **Transparent**: background shows through on Chrome/Firefox; opaque on Safari | `ffmpeg -f lavfi -i "color=c=black@0.0:s=640x480:rate=30,format=yuva420p" -f lavfi -i "color=c=red:s=80x80:rate=30,format=yuva420p" -filter_complex "[0][1]overlay=x='(W-w)*(1-cos(2*PI*t/5))/2':y=200:format=auto" -c:v libvpx-vp9 -pix_fmt yuva420p -auto-alt-ref 0 -t 15 test_transparent.webm` |

**Visual Demo** (checkerboard shows through the transparent regions; the red square moves left and right every 5 seconds):

<div style="display:inline-block;padding:10px;border-radius:8px;background-color:#808080;background-image:linear-gradient(45deg,#ccc 25%,transparent 25%),linear-gradient(-45deg,#ccc 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#ccc 75%),linear-gradient(-45deg,transparent 75%,#ccc 75%);background-size:24px 24px;background-position:0 0,0 12px,12px -12px,-12px 0;">
  <video width="640" height="480" autoplay loop muted playsinline src="videos/test_transparent.webm"></video>
</div>

## 8. HDR Subtitle Rendering (BT.2020 HLG and PQ)

The two 10-bit HEVC samples share a fixed gray background and the same default ASS subtitle track. Play both in FSPlayer or AuraPlayer on an HDR-capable display with HDR direct output enabled. Use the white swatch as a reference and compare the gray, warm, and half-transparent gray swatches. See [FSPlayer issue #5](https://github.com/debugly/fsplayer/issues/5).

| Test sample with embedded ASS | Transfer function | FSPlayer display mode |
| :--- | :--- | :--- |
| [BT.2020 HLG (MKV)](videos/test_bt2020_hlg_subtitles.mkv) | HLG (ARIB STD-B67) | Linear sRGB |
| [BT.2020 PQ (MKV)](videos/test_bt2020_pq_subtitles.mkv) | PQ (SMPTE ST 2084) with HDR10 metadata | Linear BT.2020 |

The MP4 previews below have the swatches baked into the picture for browsers that support 10-bit HEVC. From left to right they show white, `#808080` gray, `#C08040` warm color, and gray at 50% opacity. Use the MKV files to exercise the player's subtitle renderer.

**[BT.2020 HLG MP4](videos/previews/test_bt2020_hlg_subtitles.mp4)**

<video style="width:100%;max-width:640px;height:auto" width="640" height="360" controls muted playsinline preload="metadata" aria-label="BT.2020 HLG subtitle swatches" src="videos/previews/test_bt2020_hlg_subtitles.mp4"></video>

**[BT.2020 PQ MP4](videos/previews/test_bt2020_pq_subtitles.mp4)**

<video style="width:100%;max-width:640px;height:auto" width="640" height="360" controls muted playsinline preload="metadata" aria-label="BT.2020 PQ subtitle swatches" src="videos/previews/test_bt2020_pq_subtitles.mp4"></video>
