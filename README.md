# MRFFToolChain Build Shell

## Foreword

**What's MRFFToolChain?**

MRFFToolChain products was built for my FFmepg tutorial : [https://github.com/debugly/FFmpegTutorial](https://github.com/debugly/FFmpegTutorial) .

At present MRFFToolChain contained OpenSSL、FFmpeg 、Lame、X264、Fdk-aac build shell...

All MRFFToolChain lib were made to Pod in [MRFFToolChainPod](https://github.com/debugly/MRFFToolChainPod/). 

## Folder structure

```
.
├── README.md
├── config          #ffmpeg 功能裁剪配置
├── extra           #ffmpeg，openssl 等库的源码
├── init-ffmpeg.sh  #ffmpeg 源码初始化脚本
├── init-openssl.sh #openssl 源码初始化脚本
├── ios             #ios 平台编译工作目录
├── mac             #macos 平台编译工作目录
├──tools            #编译脚本通用依赖
# 后续将废弃掉
├── MakePod
├── build
├── build-fdk-aac.sh
├── build-lame.sh
├── build-x264.sh
└── product
```

## Build OpenSSL

1、按平台准备源码

```
#准备 iOS 和 macOS 平台源码
./init-openssl.sh all
#准备 iOS 平台源码
./init-openssl.sh ios
#准备 macOS 平台源码
./init-openssl.sh macos
#第二个参数可选
#准备 macOS 平台 arm 架构源码
./init-openssl.sh macos arm64
```

2、按平台分别编译

```
# 编译 iOS 平台
cd ios
./compile-openssl.sh all 	# 编译 x86_64 和 arm64 架构
./compile-openssl.sh x86_64# 仅编译 x86_64 架构
./compile-openssl.sh arm64 # 仅编译 arm64 架构
./compile-openssl.sh lipo  # 将编译好的不同架构库合并成 fat 版本
./compile-openssl.sh clean # 清理构建产物包括 .o 和 .a
./compile-openssl.sh clean x86_64 # 仅清理 x86_64 架构的构建产物
./compile-openssl.sh clean arm64  # 仅清理 arm64 架构的构建产物
./compile-openssl.sh check # 检查编译工具

# 制作 Pod 库物料
cd make-openssl-pod
# 跟上当前库的版本，比如 1.1.1l
./make-pod.sh 1.1.1l
# 将 podspec 和 zip 文件上传到服务器即可
```

```
# 编译 macOS 平台
cd mac
./compile-openssl.sh all 	# 编译 x86_64 和 arm64 架构
./compile-openssl.sh x86_64# 仅编译 x86_64 架构
./compile-openssl.sh arm64 # 仅编译 arm64 架构
./compile-openssl.sh lipo  # 将编译好的不同架构库合并成 fat 版本
./compile-openssl.sh clean # 清理构建产物包括 .o 和 .a
./compile-openssl.sh clean x86_64 # 仅清理 x86_64 架构的构建产物
./compile-openssl.sh clean arm64  # 仅清理 arm64 架构的构建产物
./compile-openssl.sh check # 检查编译工具

# 制作 Pod 库物料
cd make-openssl-pod
# 跟上当前库的版本，比如 4.4
./make-pod.sh 4.4
# 将 podspec 和 zip 文件上传到服务器即可
```

## Build FFmepg

> 如果需要编译支持 https 协议的 ffmpeg，需要先编译 openssl，然后再往下编译 ffmpeg！


1、按平台准备源码

```
#准备 iOS 和 macOS 平台源码
./init-ffmpeg.sh all
#准备 iOS 平台源码
./init-ffmpeg.sh ios
#准备 macOS 平台源码
./init-ffmpeg.sh macos
#第二个参数可选
#准备 macOS 平台 arm 架构源码
./init-ffmpeg.sh macos arm64
```

2、按平台分别编译

```
# 编译 iOS 平台
cd ios
./compile-ffmpeg.sh all 	# 编译 x86_64 和 arm64 架构
./compile-ffmpeg.sh x86_64# 仅编译 x86_64 架构
./compile-ffmpeg.sh arm64 # 仅编译 arm64 架构
./compile-ffmpeg.sh lipo  # 将编译好的不同架构库合并成 fat 版本
./compile-ffmpeg.sh clean # 清理构建产物包括 .o 和 .a
./compile-ffmpeg.sh clean x86_64 # 仅清理 x86_64 架构的构建产物
./compile-ffmpeg.sh clean arm64  # 仅清理 arm64 架构的构建产物
./compile-ffmpeg.sh check # 检查编译工具

# 制作 Pod 库物料
cd make-ffmpeg-pod
# 跟上当前库的版本，比如 4.4
./make-pod.sh 4.4
# 将 podspec 和 zip 文件上传到服务器即可
```

```
# 编译 macOS 平台
cd mac
./compile-ffmpeg.sh all 	# 编译 x86_64 和 arm64 架构
./compile-ffmpeg.sh x86_64# 仅编译 x86_64 架构
./compile-ffmpeg.sh arm64 # 仅编译 arm64 架构
./compile-ffmpeg.sh lipo  # 将编译好的不同架构库合并成 fat 版本
./compile-ffmpeg.sh clean # 清理构建产物包括 .o 和 .a
./compile-ffmpeg.sh clean x86_64 # 仅清理 x86_64 架构的构建产物
./compile-ffmpeg.sh clean arm64  # 仅清理 arm64 架构的构建产物
./compile-ffmpeg.sh check # 检查编译工具

# 制作 Pod 库物料(如果制作的是不依赖于 openssl 的，则进入 make-ffmpeg-pod/No-OpenSSL 目录)
cd make-ffmpeg-pod/OpenSSL
# 跟上当前库的版本，比如 4.4
./make-pod.sh 4.4
# 将 podspec 和 zip 文件上传到服务器即可
```

## build fdk-aac

build iOS fat (arm64,x86_64) lib : `sh build-fdk-aac.sh -c -a all`

```
====Clean====
old product exist
product has been cleaned.
==========================================

===================================
✅ gas-preprocessor.pl exist!
===================================


===================================
✅ Fdk-aac 2.0.1 source exist!
===================================

will build arm64...

===Build Info==========
Fdk-aac 2.0.1
ARCH : arm64
CC : xcrun -sdk iphoneos clang -arch arm64
CXX : xcrun -sdk iphoneos clang++ -arch arm64
AS : gas-preprocessor.pl -arch aarch64 -- xcrun -sdk iphoneos clang -arch arm64
Prefix : /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/fdk-aac/fdk-aac-2.0.1-thin/arm64
CFLAGS : -arch arm64 -mios-version-min=8.0 -fembed-bitcode -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
CONFIGURE_FLAGS : --disable-shared --enable-static --with-sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
=========================================================

arm64 successfully built.
will build x86_64...

===Build Info==========
Fdk-aac 2.0.1
ARCH : x86_64
CC : xcrun -sdk iphonesimulator clang -arch x86_64
CXX : xcrun -sdk iphonesimulator clang++ -arch x86_64
AS : gas-preprocessor.pl -- xcrun -sdk iphonesimulator clang -arch x86_64
Prefix : /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/fdk-aac/fdk-aac-2.0.1-thin/x86_64
CFLAGS : -arch x86_64 -mios-simulator-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
CONFIGURE_FLAGS : --disable-shared --enable-static --with-sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
=========================================================

x86_64 successfully built.
will make fat lib: libfdk-aac.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/fdk-aac/fdk-aac-2.0.1/lib/libfdk-aac.a are: x86_64 arm64 
header already right.
🎉  Congrats
🚀  Fdk-aac 2.0.1 successfully built
```

more cmd opts

```
sh build-fdk-aac.sh -h
SYNOPSIS
    sh build-fdk-aac.sh -h 
        ** show useage **
    sh build-fdk-aac.sh -v 
        ** print more log **
    sh build-fdk-aac.sh -c 
        ** clean product **
    sh build-fdk-aac.sh -l 
        ** lipo libs **
    sh build-fdk-aac.sh -a [arm64,x86_64,all] 
        ** build special arch **
    sh build-fdk-aac.sh -c -a all 
        ** build special arch **
    sh build-fdk-aac.sh -v -c -a all 
        ** show more log, after clean old produt then build all arch **
```

## Build Lame

build iOS fat (arm64,x86_64) lib : `sh build-lame.sh -c -a all`

```
====Clean====
old product exist
product has been cleaned.
==========================================

===================================
✅ Lame 3.100 source exist!
===================================


===Build Info==========
Lame 3.100
ARCH : arm64
CC : xcrun -sdk iphoneos clang -arch arm64
AS : 
Prefix : /arm64
CFLAGS : -arch arm64 -mios-version-min=8.0 -fembed-bitcode -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
CONFIGURE_FLAGS : --disable-shared --enable-static 				 --disable-frontend                  --disable-debug --with-sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
=========================================================

arm64 successfully built.

===Build Info==========
Lame 3.100
ARCH : x86_64
CC : xcrun -sdk iphonesimulator clang -arch x86_64
AS : 
Prefix : /x86_64
CFLAGS : -arch x86_64 -mios-simulator-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
CONFIGURE_FLAGS : --disable-shared --enable-static 				 --disable-frontend                  --disable-debug --with-sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
=========================================================

x86_64 successfully built.
will make fat lib: libmp3lame.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/lame/lame-3.100/lib/libmp3lame.a are: x86_64 arm64 
header already right.
🎉  Congrats
🚀  Lame 3.100 successfully built
```

more cmd opts

```
sh build-lame.sh -h
SYNOPSIS
    sh build-lame.sh -h 
        ** show useage **
    sh build-lame.sh -v 
        ** print more log **
    sh build-lame.sh -c 
        ** clean product **
    sh build-lame.sh -l 
        ** lipo libs **
    sh build-lame.sh -a [arm64,x86_64,all] 
        ** build special arch **
    sh build-lame.sh -c -a all 
        ** build special arch **
    sh build-lame.sh -v -c -a all 
        ** show more log, after clean old produt then build all arch **
```

## Build x264

build iOS fat (arm64,x86_64) lib : `sh build-x264.sh -c -a all`

```
====Clean====
old product exist
product has been cleaned.
==========================================

===================================
✅ gas-preprocessor.pl exist!
===================================


===================================
✅ x264 20191217-2245 source exist!
===================================

will build arm64...

===Build Info==========
x264 20191217-2245
ARCH : arm64
CC : xcrun -sdk iphoneos clang -arch arm64
AS : gas-preprocessor.pl -arch aarch64 -- xcrun -sdk iphoneos clang -arch arm64
Prefix : /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/x264/x264-20191217-2245-thin/arm64
CFLAGS : -arch arm64 -mios-version-min=8.0 -fembed-bitcode -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
CONFIGURE_FLAGS : --enable-static --enable-pic --disable-cli --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
=========================================================

arm64 successfully built.
will build x86_64...

===Build Info==========
x264 20191217-2245
ARCH : x86_64
CC : xcrun -sdk iphonesimulator clang -arch x86_64
AS : 
Prefix : /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/x264/x264-20191217-2245-thin/x86_64
CFLAGS : -arch x86_64 -mios-simulator-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
CONFIGURE_FLAGS : --enable-static --enable-pic --disable-cli --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk --disable-asm
=========================================================

x86_64 successfully built.
will make fat lib: libx264.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/x264/x264-20191217-2245/lib/libx264.a are: x86_64 arm64 
header already right.
🎉  Congrats
🚀  x264 20191217-2245 successfully built
```

more cmd opts

```
sh build-x264.sh -h
SYNOPSIS
    sh build-x264.sh -h 
        ** show useage **
    sh build-x264.sh -v 
        ** print more log **
    sh build-x264.sh -c 
        ** clean product **
    sh build-x264.sh -l 
        ** lipo libs **
    sh build-x264.sh -a [arm64,x86_64,all] 
        ** build special arch **
    sh build-x264.sh -c -a all 
        ** build special arch **
    sh build-x264.sh -v -c -a all 
        ** show more log, after clean old produt then build all arch **
```
