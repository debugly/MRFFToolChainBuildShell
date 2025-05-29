#!/bin/zsh

set -e

LIB_NAME=$1
PLAT=$2

case $LIB_NAME in
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
            ./main.sh install -l 'harfbuzz fribidi unibreak fontconfig' -p android
        fi
    ;;
    bluray)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'xml2' -p ios
            ./main.sh install -l 'xml2' -p tvos
            ./main.sh install -l 'xml2' -p macos
            ./main.sh install -l 'xml2' -p android
        elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'xml2' -p ios
            ./main.sh install -l 'xml2' -p tvos
            ./main.sh install -l 'xml2' -p macos
        else
            ./main.sh install -l 'xml2' -p $PLAT
        fi
    ;;
    ffmpeg)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p ios
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p tvos
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p macos
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p android
        elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p ios
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p tvos
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p macos
        else
            ./main.sh install -l 'openssl opus dav1d dvdnav uavs3d smb2 bluray' -p $PLAT
        fi
    ;;
    ijkffmpeg)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'openssl' -p ios
            ./main.sh install -l 'openssl' -p tvos
            ./main.sh install -l 'openssl' -p macos
            ./main.sh install -l 'openssl' -p android
        elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'openssl' -p ios
            ./main.sh install -l 'openssl' -p tvos
            ./main.sh install -l 'openssl' -p macos
        else
            ./main.sh install -l 'openssl' -p $PLAT
        fi
    ;;
    fftutorial)
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'openssl' -p ios
            ./main.sh install -l 'openssl' -p tvos
            ./main.sh install -l 'openssl' -p macos
            ./main.sh install -l 'openssl' -p android
        elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'openssl' -p ios
            ./main.sh install -l 'openssl' -p tvos
            ./main.sh install -l 'openssl' -p macos
        else
            ./main.sh install -l 'openssl' -p $PLAT
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
        if [[ $PLAT == all ]];then
            ./main.sh install -l 'xml2' -p ios
            ./main.sh install -l 'xml2' -p tvos
            ./main.sh install -l 'xml2' -p macos
            ./main.sh install -l 'xml2' -p android
        elif [[ $PLAT == apple ]];then
            ./main.sh install -l 'xml2' -p ios
            ./main.sh install -l 'xml2' -p tvos
            ./main.sh install -l 'xml2' -p macos
        else
            ./main.sh install -l 'xml2' -p $PLAT
        fi
        if [[ $PLAT == android || $PLAT == all ]];then
            ./main.sh install -p android -l 'freetype'
        fi
    ;;
    dvdnav)
        ./main.sh install -l 'dvdread' -p $PLAT
    ;;
    *)
    ;;
esac
