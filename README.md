## MRFFToolChain Build Shell \[[中文版](./README_zh-CN.md)\]

        

## What is MRFFToolChain?

MRFFToolChain cross-compiles FFmpeg (4.x–8.x) and 25+ third-party libraries — ass, dav1d, x264, x265, openssl, bluray, and more — for **iOS, macOS, tvOS, Android, and HarmonyOS**, then publishes the pre-built binaries to GitHub Releases. Stop fighting cross-compilation: download a ready-made library and link it in one command.

It powers [fsplayer](https://github.com/debugly/fsplayer), [ijkplayer](https://github.com/debugly/ijkplayer), and [FFmpegTutorial](https://github.com/debugly/FFmpegTutorial).

Libraries included: `ass、bluray、dav1d、dovi、dvdread、dvdnav、ffmpeg、freetype、fribidi、harfbuzz、lcms2、placebo、moltenvk、openssl、opus、shaderc、smb2、soundtouch、unibreak、uavs3d、xml2、yuv、webp、x264、x265`.

## Why MRFFToolChain?


| You get                                                      | Instead of                                                |
| ------------------------------------------------------------ | --------------------------------------------------------- |
| ✅ Pre-built binaries on GitHub Releases                      | ❌ Setting up each cross-compile toolchain by hand         |
| ✅ One-command install (`./main.sh install -p ios -l ffmpeg`) | ❌ Running `./configure && make` for every lib, every arch |
| ✅ 25+ libraries with patches already applied                 | ❌ Hunting down and applying patches yourself              |
| ✅ 5 platforms (iOS / macOS / tvOS / Android / HarmonyOS)     | ❌ Maintaining a separate build script per platform        |
| ✅ FFmpeg 4.0.5 → 8.1.2 (five versions)                       | ❌ Only the latest commit                                  |
| ✅ Self-hostable mirrors (`MR_DOWNLOAD_BASEURL`)              | ❌ Locked to one slow source                               |


## Supported Platforms


| platform  | architectures                             | minimum deployment target |
| --------- | ----------------------------------------- | ------------------------- |
| iOS       | arm64、arm64\_simulator、x86\_64\_simulator | 12.0                      |
| tvOS      | arm64、arm64\_simulator、x86\_64\_simulator | 12.0                      |
| macOS     | arm64、x86\_64                             | 10.14                     |
| Android   | arm64、armv7a、x86\_64、x86                  | 21                        |
| HarmonyOS | arm64、x86\_64                             | 5.0.0 (API 12)            |


## News

- FFmpeg **8.1.2** is ready
- HarmonyOS support is ready
- Upgraded all libraries to latest, with improved optimizations
- Built with macOS 15 and Xcode 16.4

## Dependencies

- Fontconfig: xml2,freetype
- Bluray: xml2
- Harfbuzz: freetype
- Dvdnav: dvdread
- Placebo for macOS: shaderc,moltenvk,dovi,lcms2
- Ass for Apple:  harfbuzz,fribidi,unibreak
- Ass for Android: harfbuzz,fribidi,unibreak,fontconfig
- IJKFFmpeg: openssl
- FFmpeg4 for Apple: openssl3,opus,bluray
- FFmpeg5 for Apple: openssl3,opus,bluray,dav1d,dvdread,uavs3d
- FFmpeg6 for Apple: openssl3,opus,bluray,dav1d,dvdread,uavs3d,smb2
- FFmpeg7 for Apple: openssl3,opus,bluray,dav1d,dvdnav,uavs3d,smb2,webp
- FFmpeg8 for Apple: openssl3,opus,bluray,dav1d,uavs3d,smb2,webp
- FFmpeg4 for Android: openssl3,opus,bluray,soundtouch
- FFmpeg5 for Android: openssl3,opus,bluray,dav1d,dvdread,uavs3d,soundtouch
- FFmpeg6 for Android: openssl3,opus,bluray,dav1d,dvdread,uavs3d,smb2,soundtouch
- FFmpeg7 for Android: openssl3,opus,bluray,dav1d,dvdnav,uavs3d,smb2,soundtouch
- FFmpeg8 for Android: openssl3,opus,bluray,dav1d,uavs3d,smb2,soundtouch
- FFmpeg8 for HarmonyOS: openssl3,opus,bluray,dav1d,uavs3d,smb2,soundtouch

Tips: 

```
1、ffmpeg is not denpendent on ass and placebo.
2、fsplayer is denpendent on ffmpeg and ass and placebo.
3、ijkplayer is denpendent on ijkffmpeg.
4、FFmpegTutorial is denpendent on fftutorial.
5、when install pre-compiled lib, will containes it's denpendencies.
```

## Download/Install Pre-compiled Libs

Save yourself a great deal of time by directly downloading the pre-compiled libraries from GitHub.
These pre-compiled libraries already applied patches which in the patches directory.

```bash
#Check the help first
./main.sh install --help
# Examples of usage:
./main.sh install -p macos -l ffmpeg
./main.sh install -p ios -l 'ass ffmpeg'
./main.sh install -p android -l openssl3
./main.sh install -p ohos -l ffmpeg8
```

## Compile by Yourself

### Initialize Library Repositories

Don't waste your time compiling these libraries unless you've modified the source code!

The script parameters are flexible and can be combined as needed. Here are some common examples:

```
# Check the help first
./main.sh init --help
# Prepare libass source code for the iOS platform
./main.sh init -p ios -l ass
# Prepare ffmpeg7 source code for the x86 architecture on iOS
./main.sh init -p ios -l ffmpeg7 -a x86_64_simulator
# Prepare source code for specific libraries for the Android platform
./main.sh init -p android -l "openssl ffmpeg"
# Prepare ffmpeg8 source code for the HarmonyOS platform
./main.sh init -p ohos -l ffmpeg8
```

### Compile

Once the source code repository initialization is complete, you can start the compilation process.

```
# Check the help first
./main.sh compile --help
# As shown in the help:
# -p specifies the platform
# -c specifies the action (e.g build for compilation, rebuild for recompilation)
# -l specifies the libraries to compile
# -a specifies the CPU architecture
```

The following code demonstrates how to compile FFmpeg 7 for the iOS platform：

```
# install FFmpeg7's dependencies has two choices
# recommend choice (because ffmpeg7 was pre-compiled,it contained all dependencies)
./main.sh install -p ios -l ffmpeg7
# other choice (you must know ffmpeg7's dependent lib name)
./main.sh install -p ios -l "openssl3 opus bluray dav1d dvdnav uavs3d smb2"
# Compile FFmpeg7 for the arm64 architecture on iOS with xcframework
./main.sh compile -p ios -a arm64 -l ffmepg7 --fmwk
```

The order of these parameters does not matter; they can be arranged in any sequence.

### Support Mirror

If cloning repositories from GitHub is slow, or if you need to use an internal private repository, you can declare the corresponding environment variables before running the compilation script!


| Lib Name   | Current Version                | Repository URL                                                                                                       | Mirror Repository URL                                     |
| ---------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| ffmpeg8    | 8.1.2                          | [https://github.com/FFmpeg/FFmpeg.git](https://github.com/FFmpeg/FFmpeg.git)                                         | export GIT\_FFMPEG\_UPSTREAM=git@xx:yy/FFmpeg.git         |
| ffmpeg7    | 7.1.3                          | [https://github.com/FFmpeg/FFmpeg.git](https://github.com/FFmpeg/FFmpeg.git)                                         | export GIT\_FFMPEG\_UPSTREAM=git@xx:yy/FFmpeg.git         |
| ffmpeg6    | 6.1.1                          | [https://github.com/FFmpeg/FFmpeg.git](https://github.com/FFmpeg/FFmpeg.git)                                         | export GIT\_FFMPEG\_UPSTREAM=git@xx:yy/FFmpeg.git         |
| ffmpeg5    | 5.1.6                          | [https://github.com/FFmpeg/FFmpeg.git](https://github.com/FFmpeg/FFmpeg.git)                                         | export GIT\_FFMPEG\_UPSTREAM=git@xx:yy/FFmpeg.git         |
| ffmpeg4    | 4.0.5                          | [https://github.com/FFmpeg/FFmpeg.git](https://github.com/FFmpeg/FFmpeg.git)                                         | export GIT\_FFMPEG\_UPSTREAM=git@xx:yy/FFmpeg.git         |
| ijkffmpeg  | ff4.0--ijk0.8.8--20210426--001 | [https://github.com/bilibili/FFmpeg.git](https://github.com/bilibili/FFmpeg.git)                                     | export GIT\_IJKFFMPEG\_UPSTREAM=git@xx:yy/FFmpeg.git      |
| ass        | 0.17.5                         | [https://github.com/libass/libass.git](https://github.com/libass/libass.git)                                         | export GIT\_ASS\_UPSTREAM=git@xx:yy/libass.git            |
| bluray     | 1.3.4                          | [https://code.videolan.org/videolan/libbluray.git](https://code.videolan.org/videolan/libbluray.git)                 | export GIT\_BLURAY\_UPSTREAM=git@xx:yy/libbluray.git      |
| dav1d      | 1.5.4                          | [https://code.videolan.org/videolan/dav1d.git](https://code.videolan.org/videolan/dav1d.git)                         | export GIT\_DAV1D\_UPSTREAM=git@xx:yy/dav1d.git           |
| dvdread    | 7.1.1                          | [https://code.videolan.org/videolan/libdvdread.git](https://code.videolan.org/videolan/libdvdread.git)               | export GIT\_DVDREAD\_UPSTREAM=git@xx:yy/libdvdread.git    |
| dvdnav     | master-9831fe01                | [https://code.videolan.org/videolan/libdvdnav.git](https://code.videolan.org/videolan/libdvdnav.git)                 | export GIT\_DVDNAV\_UPSTREAM=git@xx:yy/libdvdnav.git      |
| fontconfig | 2.18.3                         | [https://gitlab.freedesktop.org/fontconfig/fontconfig.git](https://gitlab.freedesktop.org/fontconfig/fontconfig.git) | export GIT\_FONTCONFIG\_UPSTREAM=git@xx:yy/fontconfig.git |
| freetype   | 2.14.3                         | [https://gitlab.freedesktop.org/freetype/freetype.git](https://gitlab.freedesktop.org/freetype/freetype.git)         | export GIT\_FREETYPE\_UPSTREAM=git@xx:yy/freetype.git     |
| fribidi    | 1.0.16                         | [https://github.com/fribidi/fribidi.git](https://github.com/fribidi/fribidi.git)                                     | export GIT\_FRIBIDI\_UPSTREAM=git@xx:yy/fribidi.git       |
| harfbuzz   | 14.3.1                         | [https://github.com/harfbuzz/harfbuzz.git](https://github.com/harfbuzz/harfbuzz.git)                                 | export GIT\_HARFBUZZ\_UPSTREAM=git@xx:yy/harfbuzz.git     |
| openssl    | 1.1.1w                         | [https://github.com/openssl/openssl.git](https://github.com/openssl/openssl.git)                                     | export GIT\_OPENSSL\_UPSTREAM=git@xx:yy/openssl.git       |
| openssl3   | 3.6.4                          | [https://github.com/openssl/openssl.git](https://github.com/openssl/openssl.git)                                     | export GIT\_OPENSSL\_UPSTREAM=git@xx:yy/openssl.git       |
| opus       | 1.6.1                          | [https://gitlab.xiph.org/xiph/opus.git](https://gitlab.xiph.org/xiph/opus.git)                                       | export GIT\_OPUS\_UPSTREAM=git@xx:yy/opus.git             |
| smb2       | 6.2                            | [https://github.com/sahlberg/libsmb2.git](https://github.com/sahlberg/libsmb2.git)                                   | export GIT\_SMB2\_UPSTREAM=git@xx:yy/libsmb2.git          |
| soundtouch | 2.4.1                          | [https://codeberg.org/soundtouch/soundtouch.git](https://codeberg.org/soundtouch/soundtouch.git)                     | export GIT\_SOUNDTOUCH\_UPSTREAM=git@xx:yy/soundtouch.git |
| unibreak   | 7.0                            | [https://github.com/adah1972/libunibreak.git](https://github.com/adah1972/libunibreak.git)                           | export GIT\_UNIBREAK\_UPSTREAM=git@xx:yy/libunibreak.git  |
| uavs3d     | 1.2.1                          | [https://github.com/uavs3/uavs3d.git](https://github.com/uavs3/uavs3d.git)                                           | export GIT\_UAVS3D\_UPSTREAM=git@xx:yy/UAVS3D.git         |
| xml2       | 2.15.3                         | [https://github.com/GNOME/libxml2.git](https://github.com/GNOME/libxml2.git)                                         | export GIT\_FONTCONFIG\_UPSTREAM=git@xx:yy/fontconfig.git |
| yuv        | main-f94b8cf7                  | [https://github.com/debugly/libyuv.git](https://github.com/debugly/libyuv.git)                                       | export GIT\_YUV\_UPSTREAM=git@xx:yy/yuv.git               |
| webp       | v1.6.0                         | [https://github.com/debugly/libwebp.git](https://github.com/debugly/libwebp.git)                                     | export GIT\_WEBP\_UPSTREAM=git@xx:yy/webp.git             |
| placebo    | 7.360.1                        | [https://github.com/haasn/libplacebo.git](https://github.com/haasn/libplacebo.git)                                   | export GIT\_LIBPLACEBO\_UPSTREAM=git@xx:yy/libplacebo.git |
| shaderc    | 2026.3                         | [https://github.com/google/shaderc.git](https://github.com/google/shaderc.git)                                       | export GIT\_SHADERC\_UPSTREAM=git@xx:yy/shaderc.git       |
| moltenvk   | 1.4.2                          | [https://github.com/KhronosGroup/MoltenVK.git](https://github.com/KhronosGroup/MoltenVK.git)                         | export GIT\_MOLTENVK\_UPSTREAM=git@xx:yy/MoltenVK.git     |
| lcms2      | 2.19                           | [https://github.com/mm2/Little-CMS.git](https://github.com/mm2/Little-CMS.git)                                       | export GIT\_LCMS2\_UPSTREAM=git@xx:yy/Little-CMS.git      |
| dovi       | libdovi-3.4.0                  | [https://github.com/quietvoid/dovi\_tool.git](https://github.com/quietvoid/dovi_tool.git)                            | export GIT\_DOVI\_UPSTREAM=git@xx:yy/libdovi.git          |
| x264       | master                         | [https://code.videolan.org/videolan/x264.git](https://code.videolan.org/videolan/x264.git)                           | export GIT\_X264\_UPSTREAM=git@xx:yy/x264.git             |
| x265       | 4.2                            | [https://bitbucket.org/multicoreware/x265\_git.git](https://bitbucket.org/multicoreware/x265_git.git)                | export GIT\_X265\_UPSTREAM=git@xx:yy/x265.git             |


## Tips

- To download pre-compiled xcframework libraries, add the --fmwk parameter when using the install command.
- To skip pulling remote repositories during initialization, add the --skip-pull-base parameter when using the init command.
- Currently, FFmpeg uses the **module-full.sh** configuration, resulting in slightly larger package sizes.
- You can download all pre-compiled GitHub libraries to your own server and specify your server address using MR\_DOWNLOAD\_BASEURL before running the install command.

