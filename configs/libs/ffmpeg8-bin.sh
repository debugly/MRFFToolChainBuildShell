export LIB_NAME='ffmpeg'
export ENABLE_BIN=1

if [[ "$MR_PLAT" != "macos" ]]; then
    echo "❌ ffmpeg8-bin is only supported on the macos platform."
    exit 1
fi

export LIPO_LIBS=""
export LIB_DEPENDS_BIN="nasm pkg-config"
export GIT_LOCAL_REPO=extra/ffmpeg
export REPO_DIR=ffmpeg8-bin
export PATCH_DIR=../../patches/ffmpeg8-bin
export GIT_COMMIT=n8.1.2
export GIT_REPO_VERSION=8.1.2

if [[ "$GIT_FFMPEG_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_FFMPEG_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/FFmpeg/FFmpeg.git
fi
export PRE_COMPILE_TAG_MACOS=ffmpeg8-bin-8.1.2-260714142914
