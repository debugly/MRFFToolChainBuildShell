#!/bin/sh

#
# Copyright (C) 2015-2020 Matt Reach <qianlongxu@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# directories
NAME='ffmpeg'
VERSION='3.4.7' #FFmpeg Verson '4.2.2' #2.8.15 #3.4.7
yasmTag='1.3.0' #Yasm Version

# absolute path to x264 library
#X264=`pwd`/fat-x264
#FDK_AAC=Fdk-aac/Fdk-aac-2.0.1

ARCHS="arm64 x86_64 armv7 i386"
DEPLOYMENT_TARGET="8.0"

MCB=${PWD}
BUILD="${MCB}/build"
VENDOR_SRC="${MCB}/vendor_source"
VENDOR_PROD="${MCB}/vendor_product";
PROD="${MCB}/product/${NAME}"

SOURCE="${BUILD}/${NAME}-$VERSION"
FAT="${PROD}/${NAME}-$VERSION"
SCRATCH="${PROD}/${NAME}-$VERSION-scratch"
# must be an absolute path
THIN="${PROD}/${NAME}-$VERSION-thin"
out="/dev/null"

RAW_CONFIGURE_FLAGS="--enable-cross-compile --disable-debug --disable-programs \
				 	--disable-shared --enable-static \
				 	--disable-gpl --disable-nonfree --disable-gray --disable-swscale-alpha --disable-ffprobe --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages \
					--disable-avfilter \
                 	--disable-doc --enable-pic"

export PATH=${VENDOR_PROD}/bin:$PATH

function clean(){
    # rm -rf $BUILD;
    # rm -rf $VENDOR_PROD;
	echo "====Clean===="
    if [[ -d "$PROD" ]];then
        echo 'old product exist'
        rm -rf "$PROD"
    fi
    echo "product has been cleaned."
    echo "=========================================="
}

function prepareDirs(){
    mkdir -p $BUILD;
	mkdir -p $VENDOR_SRC;
    mkdir -p $VENDOR_PROD;
	mkdir -p $PROD;
}

function dowloadYasm(){
	cd $VENDOR_SRC;
    local yasm="yasm-${yasmTag}.tar.gz"
    if [ ! -f "$yasm" ];then
        echo "======== download yasm v${yasmTag} ========"
        curl -LO http://www.tortall.net/projects/yasm/releases/$yasm || exit 1   
    fi
	cd -
    echo "✅ ${yasm} sourece prepared!"
}

function buildYasm(){
	local pwd="$PWD"

    cd $BUILD;
	local yasm=yasm-${yasmTag}.tar.gz
    tar xzpf ${VENDOR_SRC}/${yasm}
    cd "yasm-${yasmTag}"
    ./configure --prefix=${VENDOR_PROD} > $out || exit 1
	make install -j8 > $out || exit 1
	echo "✅ yasm-${yasmTag} programe prepared!"
	echo 
	cd "$pwd"
}

function checkYasm(){
	if [ ! `which yasm` ];then
		echo 'Yasm programe not found,Trying to install Yasm...'
		dowloadYasm
		buildYasm
	else
		echo
		echo '==================================='
		echo '✅ Yasm exist!'
		echo '==================================='
		echo
	fi
}

function checkGAS(){
	if [ ! `which gas-preprocessor.pl` ];then
		echo 'gas-preprocessor.pl not found. Trying to install...'
		local gas="${VENDOR_SRC}/gas-preprocessor.pl"

		if [[ ! -f "$gas" ]];then
			curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl -o "$gas" || exit 1
		fi

		local gas_bin="${VENDOR_PROD}/bin/gas-preprocessor.pl"
		mkdir -p "${VENDOR_PROD}/bin"
		
		ln -s "$gas" "$gas_bin" && chmod +x "$gas_bin" || exit 1

		echo "✅ gas-preprocessor.pl programe prepared!"
		echo
	else
		echo
		echo '==================================='
		echo '✅ gas-preprocessor.pl exist!'
		echo '==================================='
		echo
	fi
}

function checkFFmpegSource(){
	# 检查FFmpeg源码是否存在
	if [ ! -d $SOURCE ];then
		echo 'FFmpeg source not found. Trying to download...'
		cd $VENDOR_SRC
		local ffmpeg="ffmpeg-${VERSION}.tar.gz"
		if [ ! -f $ffmpeg ];then
			echo "======== download ffmpeg v${VERSION}========"
			curl -LO http://www.ffmpeg.org/releases/$ffmpeg
		fi
		# FFmpeg源码下载经常失败，所以下不成功就循环下载
		cd $BUILD
    	tar xzpf "${VENDOR_SRC}/${ffmpeg}"
		r=$?
		cd -
		if [ $r != 0 ];then
			echo "clean bad file."
			rm -f "$ffmpeg"
			rm -rf "$SOURCE"
			checkFFmpegSource
			return
		fi
		echo "✅ ${ffmpeg} prepared!"
		echo 
	else
		echo
		echo '==================================='
		echo "✅ FFmpeg Source ${VERSION} exist!"
		echo '==================================='
		echo
	fi
}

function checkVendor(){
	# checkYasm
	checkGAS
	checkFFmpegSource
}

function build_arch(){
	local ARCH="$1"
	local CWD=`pwd`

	echo "will build $ARCH..."
	mkdir -p "$SCRATCH/$ARCH"
	cd "$SCRATCH/$ARCH"

	local CFLAGS="-arch $ARCH"
	local CONFIGURE_FLAGS="$RAW_CONFIGURE_FLAGS"

	if [[ "$ARCH" = 'x86_64' || "$ARCH" = 'i386' ]]
	then
		local PLATFORM="iPhoneSimulator"
		CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-asm"
	elif [[ "$ARCH" == 'arm64' || "$ARCH" == 'armv7' ]];then
		local PLATFORM="iPhoneOS"
		CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
		if [ "$ARCH" = "arm64" ]
		then
			EXPORT="GASPP_FIX_XCODE5=1"
		fi
	else 
        echo "wrong $ARCH"
        exit 1
	fi

	local XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
	local CC="xcrun -sdk $XCRUN_SDK clang"
	local CXX="xcrun -sdk $XCRUN_SDK clang++"
	local SYS=`xcrun -sdk $XCRUN_SDK --show-sdk-path`
	
	CFLAGS="$CFLAGS -isysroot $SYS"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --sysroot=$SYS"

	# force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
	if [ "$ARCH" = "arm64" ]
	then
		local AS="gas-preprocessor.pl -arch aarch64 -- $CC"
	else
		local AS="gas-preprocessor.pl -- $CC"
	fi

	local LDFLAGS="$CFLAGS"

	if [ "$X264" ];then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl --enable-libx264"
		CFLAGS="$CFLAGS -I$X264/include"
		LDFLAGS="$LDFLAGS -L$X264/lib"
	fi

	if [ "$FDK_AAC" ];then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk-aac --enable-nonfree"
		CFLAGS="$CFLAGS -I$FDK_AAC/include"
		LDFLAGS="$LDFLAGS -L$FDK_AAC/lib"
	fi

	echo
	echo '===Build Info=========='
	echo "FFmpeg ${VERSION}"
	echo "ARCH : $ARCH"
	echo "CC : $CC"
	echo "CXX : $CXX"
	echo "AS : $AS"
	echo "Prefix : $THIN/$ARCH"
	echo "CFLAGS : $CFLAGS"
	echo "LDFLAGS : $LDFLAGS"
	echo "CONFIGURE_FLAGS : $CONFIGURE_FLAGS"
	echo '========================================================='
	echo

	$SOURCE/configure \
		--target-os=darwin \
		--arch=$ARCH \
		--cc="$CC" \
		--as="$AS" \
		--host-os="${ARCH}-apple-darwin" \
		$CONFIGURE_FLAGS \
		--extra-cflags="$CFLAGS" \
		--extra-cxxflags="$CFLAGS" \
		--extra-ldflags="$LDFLAGS" \
		--prefix="$THIN/$ARCH" \
		> $out \
	|| exit 1

	make -j8 install $EXPORT > $out || exit 1

	echo "$ARCH successfully built."
	cd $CWD
}

function buildFFmpeg()
{
	for ARCH in $ARCHS
	do
		build_arch "$ARCH"
	done
}

FF_LIBS="libavcodec libavfilter libavformat libavutil libswscale libswresample libavdevice"

function dolipo(){
    local lib="$1"
    echo "will create fat lib: $lib"
    local input=
    local output="$FAT/lib/$lib"

    if [[ -f "$output" ]];then
        rm -f "$output"
    fi

    mkdir -p "$FAT/lib/"

    for ARCH in $ARCHS
    do
        f="$THIN/$ARCH/lib/$lib"
        if [[ -f "$f" ]];then
			input="$input $f"
		fi
    done

    if [[ "$input" ]];then
        # ❌ input 不能使用引号，因为后果就是把input里的多个文件当做一个文件来对待，结果自然是找不到文件的错误！
        # xcrun lipo -create "$input" -output "$output"
        xcrun lipo -create $input -output "$output"
        xcrun lipo -info "$output"
    else
        echo "no lib to be lipoed!"
    fi
}

function cpheaders(){

	local dest="$FAT/include"

	for arch in $ARCHS
	do
		if [[ ! -d "$dest" ]];then
			local inc_dir="$THIN/$arch/include"
			if [[ -d "$inc_dir" ]];then
				cp -rf "$inc_dir" "$dest"
			fi
		fi
	done
}

function lipo(){
	for lib in $FF_LIBS
	do
		dolipo "$lib.a"
		cpheaders
	done
}

function main()
{
	echo "Use:"$(xcode-select -p)
	preapare
	buildFFmpeg
	echo "building fat binaries..."
	lipo
	echo "🎉  Congrats"
    echo "🚀  FFmpeg ${VERSION} successfully built"
}

function preapare(){
	prepareDirs
	checkVendor
}

function usage(){
cat << EOF
SYNOPSIS
    sh `basename $0` -h 
        ** show useage **
    sh `basename $0` -v 
        ** print more log **
    sh `basename $0` -c 
        ** clean product **
    sh `basename $0` -l 
        ** lipo libs **
    sh `basename $0` -a [$ARCHS] 
        ** build special arch **
    sh `basename $0` -c -a all 
        ** build special arch **
    sh `basename $0` -v -c -a all 
        ** show more log, after clean old produt then build all arch **
EOF
}

if [ "$1" == "" ]; then
    usage
    exit 1
fi

while getopts "hvcla:" OPTION; do
    case $OPTION in
         h)
             usage
             exit 1
             ;;
         c)
             clean
             ;;
         v)
             out="/dev/stdout"
             ;;
         l)
		 	 preapare
             lipo
             ;;
         a)

            ok=
            if [[ "all" == "$OPTARG" ]];then
                main
                ok="yes"
            fi

            for arch in $ARCHS
            do
                if [[ "$arch" == "$OPTARG" ]];then
					preapare
                    build_arch $arch
                    ok="yes"
                fi
            done
            
            if [[ ! "$ok" ]];then
                echo "wrong opts:$OPTARG!"
                echo 'sh build-ffmpeg.sh -a '"[$ARCHS]" 
                exit 1
            fi

            ;;
         ?)
             usage
             exit 1
             ;;
    esac
done

shift $(($OPTIND - 1))

if [ "x$1" != "x" ]; then
    echo "wrong opts:$1"
    usage
    exit 1
fi