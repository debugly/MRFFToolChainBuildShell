#! /usr/bin/env bash

# module 文件是通过 source 的方式加载的，因此 $0 指的是调用方：./do-compile/apple/ffmpeg.sh
# BASH_SOURCE 是个栈，里面存了调用时文件列表
# source 执行好处是在当前进程里执行的，因此所有上下文共用，声明的环境变量等在执行完文件后，仍旧有效
# "副作用": 覆盖同名变量，$0 不是当前文件路径，修改了自己的工作目录就等于修改调用者的目录等。

enter_path=$PWD
dir=$(dirname ${BASH_SOURCE[0]}) && pwd
source $dir/module-full.sh
cd ${enter_path}

# enable programs 
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-avdevice"
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-avfilter"
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-ffmpeg"
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-ffplay"
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-ffprobe"

# enable virtual and capture indevs for the binary program
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-indev=lavfi,testsrc,sine"
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-encoder=aac"

# freetype 让 drawtext 滤镜可用（生成测试图卡的帧号/时码）；ffmpeg 8 起 drawtext 的
# 依赖是 "libfreetype libharfbuzz"，两个都要开，缺一个 configure 就不会启用该滤镜。
# 依赖由 .github/workflows/install-dependencies.sh 里的 ass 传递安装（ass → harfbuzz → freetype）。
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-libfreetype"
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-libharfbuzz"

if [[ "$MR_PLAT" == "macos" ]]; then
    export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-indev=avfoundation,openal"
    export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-outdev=audiotoolbox"
    # 显式启用 VideoToolbox hevc(H.265) 与 H.264 硬件加速编码器，以及 AudioToolbox AAC 编码器
    export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-encoder=hevc_videotoolbox"
    export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-encoder=h264_videotoolbox"
    export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-encoder=aac_at"
fi