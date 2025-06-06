## MRFFToolChain Build Shell

![](https://img.shields.io/github/downloads/debugly/MRFFToolChainBuildShell/total) <img src="https://img.shields.io/badge/Platform-%20iOS%20macOS%20tvOS%20Android-blue.svg"><img src="https://img.shields.io/badge/FFmpeg-%207.1.1%20-blue.svg"><img src="https://img.shields.io/badge/FFmpeg-%206.1.1%20-blue.svg"><img src="https://img.shields.io/badge/FFmpeg-%205.1.6%20-blue.svg"><img src="https://img.shields.io/badge/FFmpeg-%204.0.5%20-blue.svg">

**What's MRFFToolChain?**

MRFFToolChain products was built for [fsplayer](https://github.com/debugly/fsplayer) 、 [ijkplayer](https://github.com/debugly/ijkplayer) 、[FFmpegTutorial](https://github.com/debugly/FFmpegTutorial).

At present MRFFToolChain contained `ass、bluray、dav1d、dvdread、dvdnav、ffmpeg、freetype、fribidi、harfbuzz、openssl、opus、unibreak、uavs3d、smb2、yuv、soundtouch、xml2`.

## Supported Plat

| platform | architectures                          | minimum deployment target |
| -------- | -------------------------------------- | ------------------------- |
| iOS      | arm64、arm64_simulator、x86_64_simulator | 11.0                      |
| tvOS     | arm64、arm64_simulator、x86_64_simulator | 12.0                      |
| macOS    | arm64、x86_64                           | 10.11                     |
| Android  | arm64、armv7a、x86_64、x86                | 21                        |

## News

- FFmpeg 7.1.1 is already in use
- upgrade all libs to lastest,Improved optimizations
- using macOS 14, remove bitcode support

[https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes#Deprecations](https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes#Deprecations)

## Denpendency

- Fontconfig: xml2,freetype
- Bluray: xml2
- Harfbuzz: freetype
- dvdnav: dvdread
- Ass for Appple:  harfbuzz,fribidi,unibreak
- Ass for Android: harfbuzz,fribidi,unibreak,fontconfig
- FFmpeg4 for Appple: openssl3,opus,bluray
- FFmpeg5 for Appple: openssl3,opus,bluray,dav1d,dvdread,uavs3d
- FFmpeg6 for Appple: openssl3,opus,bluray,dav1d,dvdread,uavs3d,smb2
- FFmpeg7 for Appple: openssl3,opus,bluray,dav1d,dvdnav,uavs3d,smb2
- FFmpeg4 for Android: openssl3,opus,bluray,soundtouch
- FFmpeg5 for Android: openssl3,opus,bluray,dav1d,dvdread,uavs3d,soundtouch
- FFmpeg6 for Android: openssl3,opus,bluray,dav1d,dvdread,uavs3d,smb2,soundtouch
- FFmpeg7 for Android: openssl3,opus,bluray,dav1d,dvdnav,uavs3d,smb2,soundtouch

Tips: 

```
1、ffmpeg is not denpendent on ass.
2、fsplayer is denpendent on ffmpeg and ass.
3、ijkplayer is denpendent on ijkffmpeg.
4、FFmpegTutorial is denpendent on fftutorial.
4、when install pre-compiled lib, will containes it's denpendencies.
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
```

## Compile by Yourself

### Initialize Library Repositories

Don't waste your time compiling these libraries unless you've modified the source code!
Why not just download the pre-compiled libraries I've prepared using GitHub actions?

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
```

### Compile

Once the source code repository initialization is complete, you can start the compilation process.

```
# Check the help first
./main.sh compile --help
# As shown in the help:
# -p specifies the platform
# -c specifies the action (e.g., build for compilation, rebuild for recompilation)
# -l specifies the libraries to compile
# -a specifies the CPU architecture
```

The following code demonstrates how to compile FFmpeg 7 for the iOS platform：

```
# install FFmpeg7's dependencies has two choices
# recommend choice (because ffmpeg7 was pre-compiled,it contained all dependencies)
./main.sh install -p ios -l ffmpeg7
# other choice (you must know ffmpeg7's dependent lib name)
./main.sh install -p ios -l "openssl3 opus bluray dav1d dvdnav uavs3d,smb2"
# Compile FFmpeg7 for the arm64 architecture on iOS
./main.sh compile -p ios -a arm64 -l ffmepg7 --skip-fmwk
```

The order of these parameters does not matter; they can be arranged in any sequence.

### Support Mirror

If cloning repositories from GitHub is slow, or if you need to use an internal private repository, you can declare the corresponding environment variables before running the compilation script!

| Lib Name   | Current Version | Repository URL                                           | Mirror Repository URL                                    |
| ---------- | --------------- | -------------------------------------------------------- | -------------------------------------------------------- |
| FFmpeg     | 7.1.1           | https://github.com/FFmpeg/FFmpeg.git                     | export GIT_FFMPEG_UPSTREAM = git@xx:yy/FFmpeg.git        |
| ass        | 0.17.3          | https://github.com/libass/libass.git                     | export GIT_ASS_UPSTREAM = git@xx:yy/libass.git           |
| bluray     | 1.3.4           | https://code.videolan.org/videolan/libbluray.git         | export GIT_BLURAY_UPSTREAM = git@xx:yy/libbluray.git     |
| dav1d      | 1.5.1           | https://code.videolan.org/videolan/dav1d.git             | export GIT_DAV1D_UPSTREAM = git@xx:yy/dav1d.git          |
| dvdread    | 6.1.3           | https://code.videolan.org/videolan/libdvdread.git        | export GIT_DVDREAD_UPSTREAM = git@xx:yy/libdvdread.git   |
| dvdnav     | master-9831fe01 | https://code.videolan.org/videolan/libdvdnav.git         | export GIT_DVDNAV_UPSTREAM = git@xx:yy/libdvdnav.git     |
| fontconfig | 2.16.0          | https://gitlab.freedesktop.org/fontconfig/fontconfig.git | export GIT_FONTCONFIG_UPSTREAM=git@xx:yy/fontconfig.git  |
| freetype   | 2.13.3          | https://gitlab.freedesktop.org/freetype/freetype.git     | export GIT_FREETYPE_UPSTREAM = git@xx:yy/freetype.git    |
| fribidi    | 1.0.16          | https://github.com/fribidi/fribidi.git                   | export GIT_FRIBIDI_UPSTREAM = git@xx:yy/fribidi.git      |
| harfbuzz   | 10.2.0          | https://github.com/harfbuzz/harfbuzz.git                 | export GIT_HARFBUZZ_UPSTREAM = git@xx:yy/harfbuzz.git    |
| openssl    | 1.1.1w          | https://github.com/openssl/openssl.git                   | export GIT_OPENSSL_UPSTREAM = git@xx:yy/openssl.git      |
| openssl3    | 3.5.0          | https://github.com/openssl/openssl.git                   | export GIT_OPENSSL_UPSTREAM = git@xx:yy/openssl.git      |
| opus       | 1.5.2           | https://gitlab.xiph.org/xiph/opus.git                    | export GIT_OPUS_UPSTREAM = git@xx:yy/opus.git            |
| smb2       | 6.2             | https://github.com/sahlberg/libsmb2.git                  | export GIT_SMB2_UPSTREAM=git@xx:yy/libsmb2.git           |
| soundtouch | 2.3.3           | https://codeberg.org/soundtouch/soundtouch.git           | export GIT_SOUNDTOUCH_UPSTREAM=git@xx:yy/soundtouch.git  |
| unibreak   | 6.1             | https://github.com/adah1972/libunibreak.git              | export GIT_UNIBREAK_UPSTREAM = git@xx:yy/libunibreak.git |
| uavs3d     | 1.2.1           | https://github.com/uavs3/uavs3d.git                      | export GIT_UAVS3D_UPSTREAM=git@xx:yy/UAVS3D.git          |
| xml2       | 2.13.6          | https://github.com/GNOME/libxml2.git                     | export GIT_FONTCONFIG_UPSTREAM=git@xx:yy/fontconfig.git  |
| yuv        | stable-eb6e7bb  | https://github.com/debugly/libyuv.git                    | export GIT_YUV_UPSTREAM=git@xx:yy/yuv.git                |

## Tips

- To download pre-compiled xcframework libraries, add the --fmwk parameter when using the install command.
- To skip pulling remote repositories during initialization, add the --skip-pull-base parameter when using the init command.
- To skip applying FFmpeg patches during initialization, add the --skip-patches parameter when using the init command.
- Currently, FFmpeg uses the module-full.sh configuration, resulting in slightly larger package sizes.
- You can download all pre-compiled GitHub libraries to your own server and specify your server address using MR_DOWNLOAD_BASEURL before running the install command.

## Donate

Compiling third-party libraries is time-consuming. I aim to contribute to the open-source community by pre-compiling all third-party libraries required by debugly/ijkplayer into static libraries and xcframeworks for public use.

If you'd like to contribute to the open-source community, consider buying me a coffee to keep me energized.

![donate.jpg](https://i.postimg.cc/xdVqnBLp/IMG-7481.jpg)
