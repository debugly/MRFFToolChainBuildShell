#!/usr/bin/env python3

"""Generate HDR playback samples and browser previews from one subtitle layout."""

import sys
from array import array
from decimal import Decimal, ROUND_CEILING
from pathlib import Path
from subprocess import run
from tempfile import TemporaryDirectory

WIDTH, HEIGHT, FPS = 1920, 1080, 24
SWATCH_WIDTH, SWATCH_HEIGHT, SWATCH_Y = 280, 120, 765
SWATCHES = (
    (220, "FFFFFF", 255, "White #FFFFFF"),
    (620, "808080", 255, "Gray #808080"),
    (1020, "C08040", 255, "Color #C08040"),
    (1420, "808080", 128, "Gray 50% opacity"),
)

# Each pair of background levels represents the same nominal luminance in HLG and PQ.
# Preview triplets are BT.2020 video-range YCbCr, with sRGB swatches composited at
# 203-nit reference white before applying the corresponding HDR transfer function.
VARIANTS = (
    ("hlg", "arib-std-b67", (280, 128, 320, 504, 760),
     ((721, 512, 512), (476, 512, 512), (506, 415, 566), (399, 512, 512))),
    ("pq", "smpte2084", (321, 167, 350, 452, 598),
     ((573, 512, 512), (439, 512, 512), (453, 459, 539), (399, 512, 512))),
)


def write_subtitles(path, duration):
    centiseconds = int((Decimal(duration) * 100).to_integral_value(rounding=ROUND_CEILING))
    if centiseconds <= 0:
        raise ValueError("Sample duration must be positive")
    seconds, fraction = divmod(centiseconds, 100)
    hours, remainder = divmod(seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    end = f"{hours}:{minutes:02d}:{seconds:02d}.{fraction:02d}"
    header = """[Script Info]
Title: HDR subtitle color test
ScriptType: v4.00+
PlayResX: 1920
PlayResY: 1080
ScaledBorderAndShadow: yes
YCbCr Matrix: None

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Swatch,Arial,40,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1
Style: Label,Arial,32,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,2,0,8,0,0,0,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"""
    lines = [header]
    for x, rgb, opacity, label in SWATCHES:
        bgr = rgb[4:6] + rgb[2:4] + rgb[:2]
        path_data = f"m 0 0 l {SWATCH_WIDTH} 0 {SWATCH_WIDTH} {SWATCH_HEIGHT} 0 {SWATCH_HEIGHT}"
        swatch = rf"{{\an7\pos({x},{SWATCH_Y})\1c&H{bgr}&\1a&H{255-opacity:02X}&\p1}}{path_data}{{\p0}}"
        label_text = rf"{{\pos({x + SWATCH_WIDTH // 2},{SWATCH_Y + SWATCH_HEIGHT + 13})}}{label}"
        lines.append(f"Dialogue: 0,0:00:00.00,{end},Swatch,,0,0,0,,{swatch}")
        lines.append(f"Dialogue: 1,0:00:00.00,{end},Label,,0,0,0,,{label_text}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def fill_box(plane, stride, x, y, width, height, code):
    row = array("H", [code]) * width
    for yy in range(y, y + height):
        start = yy * stride + x
        plane[start:start + width] = row


def make_frame(levels, preview_codes):
    luma = array("H", [levels[0]]) * (WIDTH * HEIGHT)
    cb = array("H", [512]) * (WIDTH * HEIGHT // 4)
    cr = array("H", [512]) * (WIDTH * HEIGHT // 4)
    for (x, _, _, _), level in zip(SWATCHES, levels[1:]):
        fill_box(luma, WIDTH, x, 180, SWATCH_WIDTH, 206, level)
    for (x, _, _, _), (y_code, cb_code, cr_code) in zip(SWATCHES, preview_codes):
        fill_box(luma, WIDTH, x, SWATCH_Y, SWATCH_WIDTH, SWATCH_HEIGHT, y_code)
        fill_box(cb, WIDTH // 2, x // 2, SWATCH_Y // 2, SWATCH_WIDTH // 2, SWATCH_HEIGHT // 2, cb_code)
        fill_box(cr, WIDTH // 2, x // 2, SWATCH_Y // 2, SWATCH_WIDTH // 2, SWATCH_HEIGHT // 2, cr_code)
    if sys.byteorder == "big":
        for plane in (luma, cb, cr):
            plane.byteswap()
    return luma.tobytes() + cb.tobytes() + cr.tobytes()


def encode(ffmpeg, output, transfer, duration, frame, subtitles=None):
    command = [
        ffmpeg, "-nostdin", "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pixel_format", "yuv420p10le",
        "-video_size", f"{WIDTH}x{HEIGHT}", "-framerate", str(FPS), "-i", "pipe:0",
    ]
    if subtitles is not None:
        command.extend([
            "-i", str(subtitles), "-map", "0:v:0", "-map", "1:s:0", "-c:s", "copy",
            "-metadata:s:s:0", "language=eng",
            "-metadata:s:s:0", "title=HDR subtitle swatches", "-disposition:s:0", "default",
        ])
    else:
        command.extend(["-tag:v", "hvc1", "-movflags", "+faststart+write_colr"])

    x265 = f"log-level=error:pools=4:range=limited:colorprim=bt2020:transfer={transfer}:colormatrix=bt2020nc"
    if transfer == "smpte2084":
        max_fall = 18 if subtitles is not None else 24
        x265 += (":hdr10=1:master-display=G(8500,39850)B(6550,2300)R(35400,14600)"
                 f"WP(15635,16450)L(10000000,50):max-cll=268,{max_fall}")
    command.extend([
        "-t", duration, "-vf",
        f"setparams=range=limited:color_primaries=bt2020:color_trc={transfer}:colorspace=bt2020nc,"
        f"tpad=stop_mode=clone:stop_duration={duration}",
        "-c:v", "libx265", "-preset", "ultrafast", "-crf", "12", "-profile:v", "main10",
        "-pix_fmt", "yuv420p10le", "-x265-params", x265,
        "-color_range", "tv", "-color_primaries", "bt2020",
        "-color_trc", transfer, "-colorspace", "bt2020nc", str(output),
    ])
    print(f"[*] Generating {output.name}", flush=True)
    run(command, input=frame, check=True)


def main():
    ffmpeg, duration, output_dir = sys.argv[1:]
    output = Path(output_dir)
    previews = output / "previews"
    previews.mkdir(parents=True, exist_ok=True)
    with TemporaryDirectory() as temp:
        subtitles = Path(temp) / "hdr-subtitle-swatches.ass"
        write_subtitles(subtitles, duration)
        for name, transfer, levels, preview_codes in VARIANTS:
            encode(ffmpeg, output / f"test_bt2020_{name}_subtitles.mkv", transfer,
                   duration, make_frame(levels, ()), subtitles)
            encode(ffmpeg, previews / f"test_bt2020_{name}_subtitles.mp4", transfer,
                   duration, make_frame(levels, preview_codes))


if __name__ == "__main__":
    main()
