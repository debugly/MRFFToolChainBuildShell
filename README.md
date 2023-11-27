## MRFFToolChain Build Shell

**What's MRFFToolChain?**

MRFFToolChain products was built for my FFmepg tutorial : [https://github.com/debugly/FFmpegTutorial](https://github.com/debugly/FFmpegTutorial).

At present MRFFToolChain contained OpenSSL、FFmpeg 、libyuv、libopus、libbluray、etc.

## Folder structure

```
├── README.md
├── apple        #apple平台通用编译脚本
│   ├── compile-any.sh
│   ├── compile-cfgs
│   ├── do-compile
│   └── init-env.sh
├── build       #编译目录
│   ├── extra   #源码仓库
│   ├── pre     #下载的预编译库
│   ├── product #编译产物
│   └── src     #构建时源码仓库
├── ffconfig    #ffmpeg 功能裁剪配置
│   ├── configure.md
│   ├── module-default.sh
│   ├── module-full.sh
│   ├── module-lite-hevc.sh
│   ├── module-lite.sh
│   ├── module-program.sh
│   └── module.sh -> module-full.sh
├── init-any.sh  #初始化源码仓库
├── init-cfgs    #三方库的配置，包括库名，git仓库地址等信息
│   ├── bluray
│   ├── dav1d
│   ├── ffmpeg
│   ├── libyuv
│   ├── openssl
│   └── opus
├── install-pre-any.sh #直接从github下载预编译好的lib
├── ios               #ios 平台编译脚本
│   └── compile-any.sh
├── macos             #macos 平台编译脚本
│   └── compile-any.sh
├── patches            #补丁
│   ├── README.md
│   ├── dav1d
│   ├── ffmpeg -> ffmpeg-release-5.1
│   ├── ffmpeg-n4.0
│   └── ffmpeg-release-5.1
├── tools            #基础脚本
│   ├── copy-local-repo.sh
│   ├── env_assert.sh
│   ├── init-repo.sh
│   ├── install-pre-lib.sh
│   ├── pull-repo-base.sh
│   └── pull-repo-ref.sh
└── version.sh
```

## Download Pre-compiled libs

可以跳过自己编译，直接从github上下载预编译好的库，节省时间！
预编译库已经打了 extra/patches/ 目录下的补丁，调用示例：

```bash
./install-pre-any.sh all
./install-pre-any.sh ios 'libyuv openssl opus bluray dav1d'
./install-pre-any.sh macos 'openssl'
./install-pre-any.sh macos 'openssl ffmpeg'
```

## Compile by yourself

### Init lib repos

脚本参数比较灵活，可根据需要搭配使用，常用方式举例：

```
#准备 iOS 和 macOS 平台所有库的源码
./init-any.sh all
#准备 iOS 平台源码所有库的源码
./init-any.sh ios
#准备 iOS 平台x86架构下所有库的源码
./init-any.sh ios all x86_64
#准备 macOS 平台源码所有库的源码
/init-any.sh macos
#准备 ios 平台的某些库的源码
/init-any.sh ios "openssl ffmpeg"
#准备 macOS 平台的某些库的源码
/init-any.sh macos "openssl ffmpeg"
#准备 iOS 和 macOS 平台的某些库的源码
/init-any.sh all "openssl ffmpeg"
```

### Compile

根据编译的平台，进入相应的目录，比如编译 macos 平台：

```
# 编译 macos arm64 架构下的所有库
./macos/compile-any.sh build all arm64
# 编译 macos x86_64 架构下的所有库
./macos/compile-any.sh build all x86_64
# 编译 macos 所有架构下的所有库
./macos/compile-any.sh build all
```

编译指定库，比如 openssl，ffmpeg

```
# 编译 macos arm64 架构 debug 版
./macos/compile-any.sh build "openssl ffmpeg" arm64 debug
# 编译 macos x86_64 架构
./macos/compile-any.sh build "openssl ffmpeg" x86_64
# 编译 macos 所有架构
./macos/compile-any.sh build "openssl ffmpeg"
```

清理 macos 平台编译产物

```
# 清理 macos arm64 架构下的所有库的产物
./macos/compile-any.sh clean all arm64
# 清理 macos x86_64 架构下的所有库的产物
./macos/compile-any.sh clean all x86_64
# 清理 macos 所有架构下的所有库的产物
./macos/compile-any.sh clean all
```

将 macos 平台编译产物合并成 fat 版本放到 universal 文件夹下（build 所有架构时会自动lipo，只有手动编译不同架构时才会用到 lipo）

```
# 合并 macos 所有架构下的所有库的产物
./macos/compile-any.sh lipo all
# 将 macos arm64 架构下的所有库的产物复制到 universal
./macos/compile-any.sh lipo all arm64
# 将 macos x86_64 架构下的所有库的产物复制到 universal
./macos/compile-any.sh lipo all x86_64
```

编译 ios 平台跟 macos 是一样的流程，只需要将 macos 改成 ios 即可。

### Support Mirror

如果 github 上的仓库克隆较慢，或者需要使用内网私有仓库，可在执行编译脚本前声明对应的环境变量！

| 名称        | 默认仓库                                             | 使用镜像                                               |
| --------- | ------------------------------------------------ | -------------------------------------------------- |
| FFmpeg    | https://github.com/bilibili/FFmpeg.git           | export GIT_FFMPEG_UPSTREAM=git@xx:yy/ffmpeg.git    |
| libYUV    | https://github.com/lemenkov/libyuv.git           | export GIT_LIBYUV_UPSTREAM=git@xx:yy/libyuv.git    |
| OpenSSL   | https://github.com/openssl/openssl.git           | export GIT_OPENSSL_UPSTREAM=git@xx:yy/openssl.git  |
| Opus      | https://gitlab.xiph.org/xiph/opus.git            | export GIT_OPUS_UPSTREAM=git@xx:yy/opusfile.git    |
| libbluray | https://code.videolan.org/videolan/libbluray.git | export GIT_BLURAY_UPSTREAM=git@xx:yy/libbluray.git |
| dav1d     | https://code.videolan.org/videolan/dav1d.git     | export GIT_DAV1D_UPSTREAM=git@xx:yy/dav1d.git      |

## Advanced Configuration

1、初始化代码仓库时：

```
   设置环境变量 export SKIP_FFMPEG_PATHCHES=1 不打 FFmpeg 补丁；
   设置环境变量 export SKIP_PULL_BASE=1 不从远程拉取最新代码；
```

2、如果不同的平台需要编译不同的库，只需要在 apple/compile-cfgs 目录下，建立 list_PLAT.txt 文件即可，PLAT 为对应的平台，比如 ios,macos 等；默认情况下按照 list.txt 里声明的顺序编译各个库。

3、ffmpeg 的配置需要分平台指定，只需要在 ffconfig 目录下创建 module_PLAT.sh 文件即可，PLAT 为对应的平台，比如 ios,macos 等；默认情况下根据 module.sh 声明的配置进行编译 ffmpeg。