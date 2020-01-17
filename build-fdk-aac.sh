#!/bin/bash

# https://sourceforge.net/projects/opencore-amr/

set -e

NAME='fdk-aac'
VERSION='2.0.1'

ARCHS="arm64 x86_64"
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

RAW_CONFIGURE_FLAGS="--disable-shared --enable-static"

export PATH=${VENDOR_PROD}/bin:$PATH

function prepareDirs(){
    mkdir -p "$BUILD"
    mkdir -p "$VENDOR_SRC"
    mkdir -p "$PROD"
}

function checkSource(){
	# 检查FFmpeg源码是否存在
	if [ ! -d $SOURCE ];then
		echo 'Fdk-aac source not found. Trying to download...'
		cd $VENDOR_SRC
		local f="${NAME}-${VERSION}.tar.gz"
		if [ ! -f "$f" ];then
			echo "======== download Fdk-aac v${VERSION}========"
			curl -LO "https://jaist.dl.sourceforge.net/project/opencore-amr/fdk-aac/$f"
		fi

		cd $BUILD
    	tar xzpf "${VENDOR_SRC}/${f}"
		r=$?
		cd -
		if [ $r != 0 ];then
			echo "clean bad file."
			rm -f "$f"
			rm -rf "$SOURCE"
			checkSource
			return
		fi
		echo "✅ ${f} prepared!"
        echo
	else
        echo
		echo '==================================='
		echo "✅ Fdk-aac ${VERSION} source exist!"
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

function build_arch(){
    
    local ARCH="$1"
    local dest="$SCRATCH/$ARCH"
    echo "will build $ARCH..."

    if [[ -d "$dest" ]];then
        rm -rf "$dest"
    fi

    mkdir -p "$dest"

    cd "$dest"
    
    local CFLAGS="-arch $ARCH"

    local kernel=`echo $(uname -s) | tr '[:upper:]' '[:lower:]'`
    # kernel_v=$(uname -r)
    if [[ "$ARCH" == 'x86_64' ]];then
        CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
        local PLATFORM="iPhoneSimulator"
        local HOST="x86_64-apple-$kernel"
    elif [[ "$ARCH" == 'arm64' ]];then
        CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
        local PLATFORM="iPhoneOS"
        local HOST="arm-apple-$kernel"
    else 
        echo "wrong $ARCH"
        exit 1
    fi

    
    local XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
    local CC="xcrun -sdk $XCRUN_SDK clang -arch $ARCH"
    local CXX="xcrun -sdk $XCRUN_SDK clang++ -arch $ARCH"
    
    local SYS=`xcrun -sdk $XCRUN_SDK --show-sdk-path`
    CFLAGS="$CFLAGS -isysroot $SYS"
    local CONFIGURE_FLAGS="$RAW_CONFIGURE_FLAGS --with-sysroot=$SYS"

    if [ "$ARCH" = "arm64" ]
	then
		local AS="gas-preprocessor.pl -arch aarch64 -- $CC"
	else
		local AS="gas-preprocessor.pl -- $CC"
	fi

    echo
    echo '===Build Info=========='
    echo "Fdk-aac ${VERSION}"
    echo "ARCH : $ARCH"
    echo "CC : $CC"
    echo "CXX : $CXX"
    echo "AS : $AS"
    echo "Prefix : $THIN/$ARCH"
    echo "CFLAGS : $CFLAGS"
    echo "CONFIGURE_FLAGS : $CONFIGURE_FLAGS"
    echo '========================================================='
    echo

    "$SOURCE"/configure \
        --prefix="$THIN/$ARCH" \
        --host="${HOST}" \
        $CONFIGURE_FLAGS \
        CC="$CC"         \
        CXX="$CXX"       \
        AS="$AS"         \
        CFLAGS="$CFLAGS" \
        LDFLAGS="$CFLAGS" \
        > $out \
    || exit 1
    
    rm -rf "$THIN/$ARCH"

    make install -j8 > $out || exit 1

    echo "$ARCH successfully built."
    cd - > $out
}

function buildAll(){
    for arch in $ARCHS
    do
        build_arch "$arch"
    done
}

function dolipo(){
    local lib="$1"
    echo "will make fat lib: $lib"
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

function lipo(){
    dolipo "libfdk-aac.a"
    cpheaders
}

function cpheaders(){
    
    local dest="$FAT/include"
    
    for ARCH in $ARCHS
    do
        # 这个条件是有用的，否则再次cp时就会把include复制到 $FAT/include 形成 $FAT/include/include
        if [[ ! -d "$dest" ]];then
            local d="$THIN/$ARCH/include"
            if [[ -d "$d" ]];then
                cp -r "$d" "$dest"
            fi
        fi
    done

    echo "header already right."
}

function clean(){
    
    echo "====Clean===="
    if [[ -d "$PROD" ]];then
        echo 'old product exist'
        rm -rf "$PROD"
    fi
    echo "product has been cleaned."
    echo "=========================================="
}

function main(){
    prepare
    buildAll
    lipo
    echo "🎉  Congrats"
    echo "🚀  Fdk-aac ${VERSION} successfully built"
}

function prepare(){
    prepareDirs
    checkGAS
    checkSource
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
    sh `basename $0` -a [arm64,x86_64,all] 
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
                echo 'sh build-lame.sh -a [arm64,x86_64,all]' 
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