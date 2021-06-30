#!/bin/sh

set -e

# directories
NAME='ffmpeg'
VERSION='4.3' #FFmpeg Verson '4.2.2' #2.8.15 #3.4.7
openSSLTag='1_1_1h' #1_0_2q'
yasmTag='1.3.0' #Yasm Version

# absolute path to x264 library
#X264=`pwd`/fat-x264
#FDK_AAC=Fdk-aac/Fdk-aac-2.0.1

ARCHS="x86_64"
DEPLOYMENT_TARGET="10.11"

MCB=${PWD}
BUILD="${MCB}/build_macos"
VENDOR_SRC="${MCB}/vendor_source"
VENDOR_PROD="${MCB}/vendor_product";
PROD="${MCB}/product_macos"
FF_PROD="${PROD}/${NAME}"

SOURCE="${BUILD}/${NAME}-$VERSION"
FAT="${FF_PROD}/${NAME}-$VERSION"
SCRATCH="${FF_PROD}/${NAME}-$VERSION-scratch"
# must be an absolute path
THIN="${FF_PROD}/${NAME}-$VERSION-thin"
out="/dev/null"
Libssl="$PROD/openssl/$openSSLTag/lib/libssl.a"

RAW_CONFIGURE_FLAGS="--disable-debug --disable-programs \
				 	--disable-shared --enable-static \
				 	--disable-gpl --disable-nonfree --disable-gray --disable-swscale-alpha --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages \
                 	--disable-doc --enable-pic"

export PATH=${VENDOR_PROD}/bin:$PATH

function clean(){
    # rm -rf $BUILD;
    # rm -rf $VENDOR_PROD;
	echo "====Clean===="
    if [[ -d "$FF_PROD" ]];then
        echo 'old product exist'
        rm -rf "$FF_PROD"
    fi
    echo "product has been cleaned."
    echo "=========================================="
}

function prepareDirs(){
    mkdir -p $BUILD;
	mkdir -p $VENDOR_SRC;
    mkdir -p $VENDOR_PROD;
	mkdir -p $FF_PROD;
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

function dowloadOpenssl(){
	cd $VENDOR_SRC;
	local openSSL=OpenSSL_${openSSLTag}.tar.gz
	if [ ! -f $openSSL ];then
		echo "======== download OpenSSL v${openSSLTag} ========"
		curl -LO https://github.com/openssl/openssl/archive/$openSSL
	fi
	cd -
    echo "✅ ${openSSL} sourece prepared!"
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

function buildOpenssl(){
	local pwd="$PWD"

    cd "$BUILD";
	local folder="openssl_${openSSLTag}"
	mkdir -p "$folder"
	local openSSL="${folder}.tar.gz"
    tar xzpf ${VENDOR_SRC}/${openSSL} -C "$folder" --strip-components 1
    cd "${folder}"
	# enable-ec_nistp_64_gcc_128
	local openssldir=$(dirname $Libssl)
	openssldir=$(dirname $openssldir)
	mkdir -p "$openssldir"
	echo "openssldir:$openssldir"
    ./Configure darwin64-x86_64-cc -mmacosx-version-min=$DEPLOYMENT_TARGET --prefix=${openssldir} --openssldir=${openssldir} > $out || exit 1
	make clean
	make
	make install_sw -j8 > $out || exit 1
	echo "✅ OpenSSL-${openSSLTag} lib prepared!"
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

function checkOpenssl(){
	if [ ! -f "$Libssl" ];then
		echo 'openssl lib not found,Trying to install openssl...'
		dowloadOpenssl
		buildOpenssl
		checkOpenssl
	else
		echo
		echo '==================================='
		echo '✅ Openssl exist!'
		echo '==================================='
		echo
		local openssldir=$(dirname $Libssl)
		openssldir=$(dirname $openssldir)
		OPENSSL="$openssldir"
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
	checkYasm
	checkOpenssl
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

	if [[ "$ARCH" = 'x86_64' ]]
	then
		local PLATFORM="MacOSX"
		CFLAGS="$CFLAGS -mmacosx-version-min=$DEPLOYMENT_TARGET"
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-asm"
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

	if [ "$OPENSSL" ];then
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-openssl"
		CFLAGS="$CFLAGS -I$OPENSSL/include"
		LDFLAGS="$LDFLAGS -L$OPENSSL/lib -lssl -lcrypto"
	fi

	echo
	echo '===Build Info=========='
	echo "FFmpeg ${VERSION}"
	echo "ARCH : $ARCH"
	echo "CC : $CC"
	echo "CXX : $CXX"
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
	prepare
	buildFFmpeg
	echo "building fat binaries..."
	lipo
	echo "🎉  Congrats"
    echo "🚀  FFmpeg ${VERSION} successfully built"
}

function prepare(){
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
		 	 prepare
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
					prepare
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