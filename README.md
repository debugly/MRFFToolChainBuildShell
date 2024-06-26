## MRFFToolChain Build Shell

**What's MRFFToolChain?**

MRFFToolChain products was built for ijkplayer : [https://github.com/debugly/ijkplayer](https://github.com/debugly/ijkplayer).

At present MRFFToolChain contained `ass、bluray、dav1d、dvdread、ffmpeg、freetype、fribidi、harfbuzz、openssl、opus、unibreak`.

## Supported Plat

| Plat  | Arch                                   |
| ----- | -------------------------------------- |
| iOS   | arm64、arm64_simulator、x86_64_simulator |
| macOS | arm64、x86_64                           |
| tvOS  | arm64、arm64_simulator、x86_64_simulator |

## Denpendency

Harfbuzz: freetype
Ass: harfbuzz fribidi unibreak
FFmpeg: openssl,opus,dav1d,dvdread

Tips: 

```
1、FFmpeg is not denpendent on Ass.
2、ijkplayer is denpendent on FFmpeg and Ass.
3、when install pre-compiled lib, will containes it's denpendencies.
```

## Folder structure

```
├── README.md
├── build       #编译目录
│   ├── extra   #源码仓库
│   ├── pre     #下载的预编译库
│   ├── product #编译产物
│   └── src     #构建时源码仓库
├── configs     #三方库配置信息
│   ├── default.sh
│   ├── ffconfig #FFmpeg功能裁剪选项
│   ├── libs     #三方库具体配置，包括库名，git仓库地址等信息
│   └── meson-crossfiles
├── do-compile   #三方库编译具体过程
│   ├── any.sh   #三方库编译通用过程
│   ├── ass.sh
│   ├── bluray.sh
│   ├── dav1d.sh
│   ├── dvdread.sh
│   ├── ffmpeg.sh
│   ├── freetype.sh
│   ├── fribidi.sh
│   ├── harfbuzz.sh
│   ├── libyuv.sh
│   ├── main.sh   #三方库编译入口
│   ├── openssl.sh
│   ├── opus.sh
│   └── unibreak.sh
├── do-init       #初始化三方库仓库
│   ├── copy-local-repo.sh
│   ├── init-repo.sh
│   └── main.sh
├── do-install    #下载安装预编译的三方库
│   ├── install-pre-lib.sh
│   ├── install-pre-xcf.sh
│   └── main.sh
├── main.sh      #脚本入口
├── patches      #给三方库打的补丁
│   ├── README.md
│   ├── bluray
│   ├── ffmpeg -> ffmpeg-release-5.1
│   ├── ffmpeg-n4.0
│   └── ffmpeg-release-5.1
└── tools
    ├── env_assert.sh
    └── export-plat-env.sh
```

## Download Pre-compiled libs

不修改三方库的源码时，没有必要自己编译，直接从 github 上下载预编译好的就行，可节省大量时间！
预编译库已经打了 patches 目录下的补丁，使用方法：

```bash
#查看帮助是个好习惯
./main.sh install -h
# 使用方式随便举例：
./main.sh install -p macos -l ffmpeg
./main.sh install -p ios -l 'ass ffmpeg'
./main.sh install -p tvos -l all
```

## Compile by yourself

### Init lib repos

脚本参数比较灵活，可根据需要搭配使用，常用方式举例：

```
#查看帮助是个好习惯
./main.sh init -h
#准备 iOS 平台源码所有库的源码
./main.sh init -p ios -l all
#准备 iOS 平台x86架构下所有库的源码
./main.sh init -p ios -l all -a x86_64_simulator
#准备 macOS 平台源码所有库的源码
./main.sh init -p macos -l all
#准备 ios 平台的某些库的源码
./main.sh init -p ios -l "openssl ffmpeg"
```

### Compile

查看帮助是个好习惯

```
./main.sh compile -h
# 根据帮助可知 -p 参数指定平台；-c 参数指定行为，比如：build是编译，rebuild是重编等; -l 指定要编译的库；-a 指定 cpu 架构。
```
使用方式随便举例：

```
#比如编译 ios 平台所有依赖库
./main.sh compile -c build -p ios -l all
#比如编译 ios 平台 arm64 架构下的 libass 库
./main.sh compile -c build -p ios -a arm64 -l ass
```

脚本对于这些参数的顺序没有要求，可以随意摆放。

### Support Mirror

如果 github 上的仓库克隆较慢，或者需要使用内网私有仓库，可在执行编译脚本前声明对应的环境变量！

| 名称          | 默认仓库                                                 | 默认版本   | 使用镜像                                                     |
| ----------- | ---------------------------------------------------- | ------ | -------------------------------------------------------- |
| libass      | https://github.com/libass/libass.git                 | 0.17.1 | export GIT_ASS_UPSTREAM = git@xx:yy/libass.git           |
| libbluray   | https://code.videolan.org/videolan/libbluray.git     | 1.3.4  | export GIT_BLURAY_UPSTREAM = git@xx:yy/libbluray.git     |
| dav1d       | https://code.videolan.org/videolan/dav1d.git         | 1.3.0  | export GIT_DAV1D_UPSTREAM = git@xx:yy/dav1d.git          |
| libdvdread  | https://code.videolan.org/videolan/libdvdread.git    | 6.1.3  | export GIT_DVDREAD_UPSTREAM = git@xx:yy/libdvdread.git   |
| FFmpeg      | https://github.com/FFmpeg/FFmpeg.git                 | 5.1.4  | export GIT_FFMPEG_UPSTREAM = git@xx:yy/FFmpeg.git        |
| freetype    | https://gitlab.freedesktop.org/freetype/freetype.git | 2.13.2 | export GIT_FREETYPE_UPSTREAM = git@xx:yy/freetype.git    |
| fribidi     | https://github.com/fribidi/fribidi.git               | 1.0.13 | export GIT_FRIBIDI_UPSTREAM = git@xx:yy/fribidi.git      |
| harfbuzz    | https://github.com/harfbuzz/harfbuzz.git             | 8.3.0  | export GIT_HARFBUZZ_UPSTREAM = git@xx:yy/harfbuzz.git    |
| openssl     | https://github.com/openssl/openssl.git               | 1.1.1w | export GIT_OPENSSL_UPSTREAM = git@xx:yy/openssl.git      |
| opus        | https://gitlab.xiph.org/xiph/opus.git                | 1.4    | export GIT_OPUS_UPSTREAM = git@xx:yy/opus.git            |
| libunibreak | https://github.com/adah1972/libunibreak.git          | 5.1    | export GIT_UNIBREAK_UPSTREAM = git@xx:yy/libunibreak.git |

## Tips

- 可下载预编译的 xcframework 库，只需要在 install 时加上 -f 参数
- 初始化仓库时，可跳过拉取远端到本地，只需要在 init 时加上 -b 参数
- 初始化仓库时，可跳过应用 FFmpeg 的补丁，只需要在 init 时加上 -k 参数
- 目前 FFmpeg 使用的是 module-full.sh 配置选项，所以包体积略大