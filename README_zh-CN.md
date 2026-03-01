## MRFFToolChain 构建脚本

![](https://img.shields.io/github/downloads/debugly/MRFFToolChainBuildShell/total) <img src="https://img.shields.io/badge/Platform-%20iOS%20macOS%20tvOS%20Android-blue.svg"> <img src="https://img.shields.io/badge/FFmpeg-%207.1.1%20-28b463.svg"> <img src="https://img.shields.io/badge/FFmpeg-%206.1.1%20-138d75.svg"> <img src="https://img.shields.io/badge/FFmpeg-%205.1.6%20-17a589.svg"> <img src="https://img.shields.io/badge/FFmpeg-%204.0.5%20-1abc9c.svg"> <img src="https://img.shields.io/badge/Xcode-%2016.4%20-bc2a9c.svg"> <img src="https://img.shields.io/badge/NDK-%2027c%20-bc2a9c.svg">

**MRFFToolChain 是什么？**

MRFFToolChain 是一套成熟的编译工具，专门用来编译 iOS、macOS、tvOS、Android 平台的三方库，其构建产物为 [fsplayer](https://github.com/debugly/fsplayer) 、 [ijkplayer](https://github.com/debugly/ijkplayer) 、[FFmpegTutorial](https://github.com/debugly/FFmpegTutorial) 所用.

目前包含了这些库：`ass、bluray、dav1d、dvdread、dvdnav、ffmpeg、freetype、fribidi、harfbuzz、openssl、opus、unibreak、uavs3d、smb2、yuv、soundtouch、xml2、webp`.

## 支持的平台

| 平台      | 架构                            | 最低部署目标版本 |
| -------- | -------------------------------------- | ------------------------- |
| iOS      | arm64、arm64_simulator、x86_64_simulator | 12.0                      |
| tvOS     | arm64、arm64_simulator、x86_64_simulator | 12.0                      |
| macOS    | arm64、x86_64                           | 10.14                     |
| Android  | arm64、armv7a、x86_64、x86                | 21                        |

## 最新动态

- FFmpeg **7.1.1** 已投入使用
- 将所有库升级至最新版本，不少库提升了性能
- 使用 macOS 15，Xcode_16.4构建

## 依赖关系

编译了适用于安卓和 iOS 平台的 FFmpeg4，FFmpeg5，FFmpeg6，FFmpeg7。

- Fontconfig：xml2、freetype
- Bluray：xml2
- Harfbuzz：freetype
- dvdnav：dvdread
- 适用于 ijkplayer 的 FFmpeg: openssl
- 适用于苹果的 Ass：harfbuzz、fribidi、unibreak
- 适用于安卓的 Ass：harfbuzz、fribidi、unibreak、fontconfig
- 适用于苹果的 FFmpeg4：openssl3、opus、bluray
- 适用于苹果的 FFmpeg5：openssl3、opus、bluray、dav1d、dvdread、uavs3d
- 适用于苹果的 FFmpeg6：openssl3、opus、bluray、dav1d、dvdread、uavs3d、smb2
- 适用于苹果的 FFmpeg7：openssl3、opus、bluray、dav1d、dvdnav、uavs3d、smb2、webp
- 适用于安卓的 FFmpeg4：openssl3、opus、bluray、soundtouch
- 适用于安卓的 FFmpeg5：openssl3、opus、bluray、dav1d、dvdread、uavs3d、soundtouch
- 适用于安卓的 FFmpeg6：openssl3、opus、bluray、dav1d、dvdread、uavs3d、smb2、soundtouch
- 适用于安卓的 FFmpeg7：openssl3、opus、bluray、dav1d、dvdnav、uavs3d、smb2、soundtouch

提示: 

```
1、ffmpeg 不依赖 ass
2、fsplayer 依赖 ffmpeg 和 ass
3、ijkplayer 依赖 ijkffmpeg
4、FFmpegTutorial 依赖 fftutorial
5、安装预编译库时，会包含其所有依赖项
```

## 下载 / 安装预编译库

直接从 GitHub 下载预编译库可以为您节省大量时间。

这些预编译库已经应用了 patches 目录下的补丁。

```bash
# 先查看帮助
./main.sh install --help
# 使用示例
./main.sh install -p macos -l ffmpeg
./main.sh install -p ios -l 'ass ffmpeg'
./main.sh install -p android -l openssl3
```

## 自行编译

### 初始化目标库仓库

除非您修改了源代码，否则不要浪费时间编译这些库！
何不直接下载我通过 GitHub 动作准备好的预编译库呢？
脚本参数灵活，可根据需要组合使用。以下是一些常见示例：

```
# 先查看帮助
./main.sh init --help
# 为 iOS 平台准备 libass 源代码
./main.sh init -p ios -l ass
# 为 iOS 的 x86 架构准备 ffmpeg7 源代码
./main.sh init -p ios -l ffmpeg7 -a x86_64_simulator
# 为 Android 平台准备特定库的源代码
./main.sh init -p android -l "openssl ffmpeg"
```

### 编译

当源代码仓库初始化完成后，就可以开始编译了。

```
# 先查看帮助
./main.sh compile --help
# 如帮助所示:
# -p 指定平台
# -c 指定操作（例如 build 用于编译，rebuild 用于重新编译）
# -l 指定要编译的库
# -a 指定 CPU 架构
```

以下代码演示如何为 iOS 平台编译 FFmpeg 7：

```
# 安装 FFmpeg7 的依赖有两种选择
# 推荐选择安装预编译方式（因为预编译的 FFmpeg7 已经包含所有依赖项）
./main.sh install -p ios -l ffmpeg7
# 另外一个选择，自己选择性地安装 FFmpeg7 的依赖库
./main.sh install -p ios -l "openssl3 opus bluray dav1d dvdnav uavs3d smb2"
# 编译 iOS 平台 arm64 架构的 FFmpeg7，并且跳过生成 xcframework
./main.sh compile -p ios -a arm64 -l ffmepg7 --skip-fmwk
```

这些参数的顺序无关紧要，可以按任意顺序排列。

### 支持镜像

如果从 GitHub 克隆仓库速度较慢，或者需要使用内部私有仓库，可以在运行编译脚本之前声明相应的环境变量！

| 库名称        | 当前版本      | 仓库 URL      | 镜像仓库 URL   |
| --------------- |----------- | ----------- | ------------ |
| ffmpeg7     | 7.1.1           | https://github.com/FFmpeg/FFmpeg.git                     | export GIT_FFMPEG_UPSTREAM=git@xx:yy/FFmpeg.git        |
| ffmpeg6     | 6.1.1           | https://github.com/FFmpeg/FFmpeg.git                     | export GIT_FFMPEG_UPSTREAM=git@xx:yy/FFmpeg.git        |
| ffmpeg5     | 5.1.6           | https://github.com/FFmpeg/FFmpeg.git                     | export GIT_FFMPEG_UPSTREAM=git@xx:yy/FFmpeg.git        |
| ffmpeg4     | 4.0.5           | https://github.com/FFmpeg/FFmpeg.git                     | export GIT_FFMPEG_UPSTREAM=git@xx:yy/FFmpeg.git        |
| ijkffmpeg   | ff4.0--ijk0.8.8--20210426--001 | https://github.com/bilibili/FFmpeg.git    | export GIT_IJKFFMPEG_UPSTREAM=git@xx:yy/FFmpeg.git     |
| ass        | 0.17.4          | https://github.com/libass/libass.git                     | export GIT_ASS_UPSTREAM=git@xx:yy/libass.git           |
| bluray     | 1.3.4           | https://code.videolan.org/videolan/libbluray.git         | export GIT_BLURAY_UPSTREAM=git@xx:yy/libbluray.git     |
| dav1d      | 1.5.3           | https://code.videolan.org/videolan/dav1d.git             | export GIT_DAV1D_UPSTREAM=git@xx:yy/dav1d.git          |
| dvdread    | 6.1.3           | https://code.videolan.org/videolan/libdvdread.git        | export GIT_DVDREAD_UPSTREAM=git@xx:yy/libdvdread.git   |
| dvdnav     | master-9831fe01 | https://code.videolan.org/videolan/libdvdnav.git         | export GIT_DVDNAV_UPSTREAM=git@xx:yy/libdvdnav.git     |
| fontconfig | 2.17.1          | https://gitlab.freedesktop.org/fontconfig/fontconfig.git | export GIT_FONTCONFIG_UPSTREAM=git@xx:yy/fontconfig.git  |
| freetype   | 2.14.1          | https://gitlab.freedesktop.org/freetype/freetype.git     | export GIT_FREETYPE_UPSTREAM=git@xx:yy/freetype.git    |
| fribidi    | 1.0.16          | https://github.com/fribidi/fribidi.git                   | export GIT_FRIBIDI_UPSTREAM=git@xx:yy/fribidi.git      |
| harfbuzz   | 12.3.2          | https://github.com/harfbuzz/harfbuzz.git                 | export GIT_HARFBUZZ_UPSTREAM=git@xx:yy/harfbuzz.git    |
| openssl    | 1.1.1w          | https://github.com/openssl/openssl.git                   | export GIT_OPENSSL_UPSTREAM=git@xx:yy/openssl.git      |
| openssl3    | 3.5.5          | https://github.com/openssl/openssl.git                   | export GIT_OPENSSL_UPSTREAM=git@xx:yy/openssl.git      |
| opus       | 1.5.2           | https://gitlab.xiph.org/xiph/opus.git                    | export GIT_OPUS_UPSTREAM=git@xx:yy/opus.git            |
| smb2       | 6.2             | https://github.com/sahlberg/libsmb2.git                  | export GIT_SMB2_UPSTREAM=git@xx:yy/libsmb2.git           |
| soundtouch | 2.4.0           | https://codeberg.org/soundtouch/soundtouch.git           | export GIT_SOUNDTOUCH_UPSTREAM=git@xx:yy/soundtouch.git  |
| unibreak   | 6.1             | https://github.com/adah1972/libunibreak.git              | export GIT_UNIBREAK_UPSTREAM=git@xx:yy/libunibreak.git |
| uavs3d     | 1.2.1           | https://github.com/uavs3/uavs3d.git                      | export GIT_UAVS3D_UPSTREAM=git@xx:yy/UAVS3D.git          |
| xml2       | 2.15.1          | https://github.com/GNOME/libxml2.git                     | export GIT_FONTCONFIG_UPSTREAM=git@xx:yy/fontconfig.git  |
| yuv        | main-f94b8cf7  | https://github.com/debugly/libyuv.git                    | export GIT_YUV_UPSTREAM=git@xx:yy/yuv.git                |
| webp       | v1.6.0 | https://github.com/debugly/libwebp.git | export GIT_WEBP_UPSTREAM=git@xx:yy/webp.git |

## 提示

- 要下载预编译的 xcframework 库，使用 install 命令时添加 --fmwk 参数
- 初始化时要跳过拉取远程仓库，使用 init 命令时添加 --skip-pull-base 参数
- 初始化时要跳过应用 FFmpeg 补丁，使用 init 命令时添加 --skip-patches 参数
- 目前 FFmpeg 使用 module-full.sh 配置，功能全但同时导致包体积略大
- 可以将所有预编译的 GitHub 库下载到自己的服务器，并在运行 install 命令前通过 MR\_DOWNLOAD\_BASEURL 指定你的服务器地址
