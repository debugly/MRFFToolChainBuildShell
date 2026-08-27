# 🌈 FFmpeg Virtual Test Sources Showcase

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
