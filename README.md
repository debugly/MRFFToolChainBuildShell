# MRFFToolChain Build Shell

## Foreword

**What's MRFFToolChain?**

MRFFToolChain was built for my FFmepg tutorial : [https://github.com/debugly/StudyFFmpeg](https://github.com/debugly/StudyFFmpeg) .

MRFFToolChain contain FFmpeg lib, Lame lib,X264 lib,Fdk-aac lib...

All MRFFToolChain lib were made to Pod in [MRFFToolChainPod](https://github.com/debugly/MRFFToolChainPod/). 

## Folder structure

```
.
├── MakePod				//make cocoapod 
├── README.md			//README
├── build				//build source folder
├── build-fdk-aac.sh	
├── build-ffmpeg.sh
├── build-lame.sh
├── build-x264.sh
├── product			//lib products
├── vendor_product  //dependent vendor products
└── vendor_source   //all lib and vendor source folder
```

```
MRFFToolChain/product/
.
├── fdk-aac
│   ├── fdk-aac-2.0.1
│   │   ├── include
│   │   └── lib
│   ├── fdk-aac-2.0.1-scratch
│   │   ├── arm64
│   │   └── x86_64
│   └── fdk-aac-2.0.1-thin
│       ├── arm64
│       └── x86_64
├── ffmpeg
│   ├── ffmpeg-3.4.7
│   │   ├── include
│   │   └── lib
│   ├── ffmpeg-3.4.7-scratch
│   │   ├── arm64
│   │   └── x86_64
│   └── ffmpeg-3.4.7-thin
│       ├── arm64
│       └── x86_64
├── lame
│   ├── lame-3.100
│   │   ├── include
│   │   └── lib
│   ├── lame-3.100-scratch
│   │   ├── arm64
│   │   └── x86_64
│   └── lame-3.100-thin
│       ├── arm64
│       └── x86_64
└── x264
    ├── x264-20191217-2245
    │   ├── include
    │   └── lib
    ├── x264-20191217-2245-scratch
    │   ├── arm64
    │   └── x86_64
    └── x264-20191217-2245-thin
        ├── arm64
        └── x86_64
```


## Build FFmepg

build iOS fat (arm64,x86_64) lib : `sh build-ffmpeg.sh -c -a all`

```
====Clean====
old product exist
product has been cleaned.
==========================================
Use:/Applications/Xcode.app/Contents/Developer

===================================
✅ gas-preprocessor.pl exist!
===================================


===================================
✅ FFmpeg Source 3.4.7 exist!
===================================

will build arm64...

===Build Info==========
FFmpeg 3.4.7
ARCH : arm64
CC : xcrun -sdk iphoneos clang
CXX : xcrun -sdk iphoneos clang++
AS : gas-preprocessor.pl -arch aarch64 -- xcrun -sdk iphoneos clang
Prefix : /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7-thin/arm64
CFLAGS : -arch arm64 -mios-version-min=8.0 -fembed-bitcode -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
LDFLAGS : -arch arm64 -mios-version-min=8.0 -fembed-bitcode -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
CONFIGURE_FLAGS : --enable-cross-compile --disable-debug --disable-programs 				 	--disable-shared --enable-static 				 	--disable-gpl --disable-nonfree --disable-gray --disable-swscale-alpha --disable-ffprobe --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages                  	--disable-doc --enable-pic --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.2.sdk
=========================================================

arm64 successfully built.
will build x86_64...

===Build Info==========
FFmpeg 3.4.7
ARCH : x86_64
CC : xcrun -sdk iphonesimulator clang
CXX : xcrun -sdk iphonesimulator clang++
AS : gas-preprocessor.pl -- xcrun -sdk iphonesimulator clang
Prefix : /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7-thin/x86_64
CFLAGS : -arch x86_64 -mios-simulator-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
LDFLAGS : -arch x86_64 -mios-simulator-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
CONFIGURE_FLAGS : --enable-cross-compile --disable-debug --disable-programs 				 	--disable-shared --enable-static 				 	--disable-gpl --disable-nonfree --disable-gray --disable-swscale-alpha --disable-ffprobe --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages                  	--disable-doc --enable-pic --disable-asm --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk
=========================================================

x86_64 successfully built.
building fat binaries...
will create fat lib: libavcodec.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libavcodec.a are: x86_64 arm64 
will create fat lib: libavfilter.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libavfilter.a are: x86_64 arm64 
will create fat lib: libavformat.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libavformat.a are: x86_64 arm64 
will create fat lib: libavutil.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libavutil.a are: x86_64 arm64 
will create fat lib: libswscale.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libswscale.a are: x86_64 arm64 
will create fat lib: libswresample.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libswresample.a are: x86_64 arm64 
will create fat lib: libavdevice.a
Architectures in the fat file: /Users/qianlongxu/Documents/GitWorkspace/MRFFToolChain/product/ffmpeg/ffmpeg-3.4.7/lib/libavdevice.a are: x86_64 arm64 
🎉  Congrats
🚀  FFmpeg 3.4.7 successfully built
```

more cmd opts

```
sh build-ffmpeg.sh -h
SYNOPSIS
    sh build-ffmpeg.sh -h 
        ** show useage **
    sh build-ffmpeg.sh -v 
        ** print more log **
    sh build-ffmpeg.sh -c 
        ** clean product **
    sh build-ffmpeg.sh -l 
        ** lipo libs **
    sh build-ffmpeg.sh -a [arm64,x86_64,all] 
        ** build special arch **
    sh build-ffmpeg.sh -c -a all 
        ** build special arch **
    sh build-ffmpeg.sh -v -c -a all 
        ** show more log, after clean old produt then build all arch **
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