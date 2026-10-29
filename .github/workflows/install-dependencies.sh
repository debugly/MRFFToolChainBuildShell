#!/bin/zsh

set -e

CONFIG_FILE="./configs/libs/${1}.sh"
if [[ -L "$CONFIG_FILE" ]]; then
    REAL_CONFIG_FILE=$(realpath "$CONFIG_FILE")
    CONFIG_BASE=$(basename "$REAL_CONFIG_FILE")
    LIB_NAME="${CONFIG_BASE%.sh}"
else
    LIB_NAME=$1
fi
PLAT=$2

# List the same dependencies used by installation without downloading anything.
function install_dependencies() {
    if [[ $LIST_DEPENDENCIES == 1 ]]; then
        local libs="" platform=""
        while (( $# )); do
            case "$1" in
                -l) libs=$2; shift 2 ;;
                -p) platform=$2; shift 2 ;;
                *) return 1 ;;
            esac
        done
        local dependency
        for dependency in ${=libs}; do
            printf '%s %s\n' "$platform" "$dependency"
        done
    else
        ./main.sh install "$@"
    fi
}

if [[ "$3" == "--list" ]]; then
    LIST_DEPENDENCIES=1
fi

case $LIB_NAME in
    test)
        case $PLAT in
            all) platforms=(ios macos tvos android ohos) ;;
            apple) platforms=(ios macos tvos) ;;
            *) platforms=("$PLAT") ;;
        esac
        for platform in "${platforms[@]}"; do
            install_dependencies -l 'ffmpeg8' -p "$platform"
        done
    ;;
    ass)
        case $PLAT in
            all) platforms=(ios macos tvos android ohos) ;;
            apple) platforms=(ios macos tvos) ;;
            *) platforms=("$PLAT") ;;
        esac
        for platform in "${platforms[@]}"; do
            if [[ $platform == ohos ]]; then
                install_dependencies -l 'freetype harfbuzz fribidi unibreak fontconfig' -p "$platform"
            elif [[ $platform == android ]]; then
                install_dependencies -l 'harfbuzz fribidi unibreak fontconfig' -p "$platform"
            else
                install_dependencies -l 'harfbuzz fribidi unibreak' -p "$platform"
            fi
        done
    ;;
    bluray)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'xml2' -p ios
            install_dependencies -l 'xml2' -p tvos
            install_dependencies -l 'xml2' -p macos
            install_dependencies -l 'xml2' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'xml2' -p ios
            install_dependencies -l 'xml2' -p tvos
            install_dependencies -l 'xml2' -p macos
        else
            install_dependencies -l 'xml2' -p $PLAT
        fi
    ;;
    ffmpeg8)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 webp' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 webp' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 webp' -p macos
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 soundtouch' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 webp' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 webp' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2 webp' -p macos
        else
            install_dependencies -l 'openssl3 opus bluray dav1d uavs3d smb2' -p $PLAT
            if [[ $PLAT == android || $PLAT == ohos ]];then
                install_dependencies -l 'soundtouch' -p $PLAT
            else
                install_dependencies -l 'webp' -p $PLAT
            fi
        fi
    ;;
    ffmpeg8-bin)
        install_dependencies -l 'ass openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp x264 x265' -p macos
    ;;
    ffmpeg7)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp' -p macos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 soundtouch' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2 webp' -p macos
        else
            install_dependencies -l 'openssl3 opus bluray dav1d dvdnav uavs3d smb2' -p $PLAT
            if [[ $PLAT == android || $PLAT == ohos ]];then
                install_dependencies -l 'soundtouch' -p $PLAT
            else
                install_dependencies -l 'webp' -p $PLAT
            fi
        fi
    ;;
    ffmpeg6)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p macos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p macos
        else
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d smb2' -p $PLAT
        fi

        if [[ $PLAT == android || $PLAT == ohos ]];then
            install_dependencies -l 'soundtouch' -p $PLAT
        fi
    ;;
    ffmpeg5)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p macos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p ios
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p tvos
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p macos
        else
            install_dependencies -l 'openssl3 opus bluray dav1d dvdread uavs3d' -p $PLAT
        fi

        if [[ $PLAT == android || $PLAT == ohos ]];then
            install_dependencies -l 'soundtouch' -p $PLAT
        fi
    ;;
    ffmpeg4)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl3 opus bluray' -p ios
            install_dependencies -l 'openssl3 opus bluray' -p tvos
            install_dependencies -l 'openssl3 opus bluray' -p macos
            install_dependencies -l 'openssl3 opus bluray' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl3 opus bluray' -p ios
            install_dependencies -l 'openssl3 opus bluray' -p tvos
            install_dependencies -l 'openssl3 opus bluray' -p macos
        else
            install_dependencies -l 'openssl3 opus bluray' -p $PLAT
        fi

        if [[ $PLAT == android || $PLAT == ohos ]];then
            install_dependencies -l 'soundtouch' -p $PLAT
        fi
    ;;
    ijkffmpeg)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl' -p ios
            install_dependencies -l 'openssl' -p tvos
            install_dependencies -l 'openssl' -p macos
            install_dependencies -l 'openssl' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl' -p ios
            install_dependencies -l 'openssl' -p tvos
            install_dependencies -l 'openssl' -p macos
        else
            install_dependencies -l 'openssl' -p $PLAT
        fi

        if [[ $PLAT == android || $PLAT == ohos ]];then
            install_dependencies -l 'soundtouch' -p $PLAT
        fi
    ;;
    fftutorial)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'openssl' -p ios
            install_dependencies -l 'openssl' -p tvos
            install_dependencies -l 'openssl' -p macos
            install_dependencies -l 'openssl' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'openssl' -p ios
            install_dependencies -l 'openssl' -p tvos
            install_dependencies -l 'openssl' -p macos
        else
            install_dependencies -l 'openssl' -p $PLAT
        fi
    ;;
    harfbuzz)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'freetype' -p ios
            install_dependencies -l 'freetype' -p tvos
            install_dependencies -l 'freetype' -p macos
            install_dependencies -l 'freetype' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'freetype' -p ios
            install_dependencies -l 'freetype' -p tvos
            install_dependencies -l 'freetype' -p macos
        else
            install_dependencies -l 'freetype' -p $PLAT
        fi
    ;;
    fontconfig)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'xml2' -p ios
            install_dependencies -l 'xml2' -p tvos
            install_dependencies -l 'xml2' -p macos
            install_dependencies -l 'xml2' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'xml2' -p ios
            install_dependencies -l 'xml2' -p tvos
            install_dependencies -l 'xml2' -p macos
        else
            install_dependencies -l 'xml2' -p $PLAT
        fi
        if [[ $PLAT == android || $PLAT == all ]];then
            install_dependencies -p android -l 'freetype'
        elif [[ $PLAT == ohos ]];then
            install_dependencies -p ohos -l 'freetype'
        fi
    ;;
    dvdnav)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'dvdread' -p ios
            install_dependencies -l 'dvdread' -p tvos
            install_dependencies -l 'dvdread' -p macos
            install_dependencies -l 'dvdread' -p android
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'dvdread' -p ios
            install_dependencies -l 'dvdread' -p tvos
            install_dependencies -l 'dvdread' -p macos
        else
            install_dependencies -l 'dvdread' -p $PLAT
        fi
    ;;
    moltenvk)
        if [[ $LIST_DEPENDENCIES != 1 ]]; then
            echo "MoltenVK has no external dependencies, it fetches its own dependencies"
        fi
    ;;
    shaderc)
        if [[ $LIST_DEPENDENCIES != 1 ]]; then
            echo "shaderc has no external dependencies, it fetches its own dependencies via git-sync-deps"
        fi
    ;;
    placebo)
        if [[ $PLAT == all ]];then
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p ios
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p tvos
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p macos
        elif [[ $PLAT == apple ]];then
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p ios
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p tvos
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p macos
        else
            install_dependencies -l 'lcms2 shaderc moltenvk dovi' -p $PLAT
        fi
    ;;
    *)
    ;;
esac
