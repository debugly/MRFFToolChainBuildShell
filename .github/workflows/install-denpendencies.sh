#!/bin/zsh

set -e

export LIB_NAME=$1
export PLAT=$2

case LIB_NAME in
    ass)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p ios
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p tvos
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p macos
            ./main.sh install -l 'harfbuzz fribidi unibreak fontconfig' -p android
            elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p ios
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p tvos
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p macos
        else
            ./main.sh install -l 'harfbuzz fribidi unibreak' -p $PLAT
        fi
    ;;
    bluray)
        if [[ $PLAT == android || $PLAT == all ]];then
            ./main.sh install -p android -l 'fontconfig'
        fi
    ;;
    dav1d)
    ;;
    dvdread)
    ;;
    ffmpeg)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p tvos
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p ios
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p macos
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p android
            elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p tvos
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p ios
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p macos
        else
            ./main.sh install -l 'openssl opus dav1d dvdread uavs3d smb2 bluray' -p $PLAT
        fi
    ;;
    harfbuzz)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'freetype' -p ios
            ./main.sh install -l 'freetype' -p tvos
            ./main.sh install -l 'freetype' -p macos
            ./main.sh install -l 'freetype' -p android
        elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'freetype' -p ios
            ./main.sh install -l 'freetype' -p tvos
            ./main.sh install -l 'freetype' -p macos
        else
            ./main.sh install -l 'freetype' -p $PLAT
        fi
    ;;
    fontconfig)
        if [[ $PLAT == android || $PLAT == all ]];then
            ./main.sh install -p android -l 'freetype'
        fi
    ;;
    freetype)
    ;;
    fribidi)
    ;;
    openssl)
    ;;
    opus)
    ;;
    smb2)
    ;;
    soundtouch)
    ;;
    uavs3d)
    ;;
    unibreak)
    ;;
    yuv)
    ;;
esac