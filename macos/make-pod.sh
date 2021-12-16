#!/bin/bash

set -e

REMOTE='https://ifoxdev.hd.sohu.com/ffpods'

function cp_product ()
{
	local prodcut="./build/universal/${LIBDIR}"
	local dest="./build/pods/${PODNAME}/macOS/${VERSION}"

	if [[ -d "$prodcut" ]];then
		rm -rf "$dest"
		mkdir -p "$dest"
		cp -rf $prodcut/* "$dest"
	else 
		echo "can't find the ${PODNAME} product in ${prodcut}"
		exit 1
	fi
}

function zip_product ()
{
	local file="${PODNAME}-macOS-${VERSION}.zip"
	cd ./build/pods
	rm -r "${file}"
	zip -ryq "${file}" ./${PODNAME}
	rm -rf ./${PODNAME}
	cd - > /dev/null
}

function make_podsepc ()
{
	local spec_name="${PODNAME}-macOS-${VERSION}"
	local REMORE_ZIP="${REMOTE}/$(date +%Y%m%d)/${spec_name}.zip"
    local pod_name="__PODNAME__"
    local pod_ver='__PODVER__'
    local bin_src='__BINARY_SRC__'
	local inc_name='__INC_NAME__'
	
	if [[ "${LIBDIR}" == 'ffmpeg' ]];then
	    local spec=$(cat ./tools/template-ffmpeg.podspec) 
	else
		local spec=$(cat ./tools/template.podspec) 
	fi

    spec=$(echo "${spec//${pod_name}/${PODNAME}}")
    spec=$(echo "${spec//${pod_ver}/${VERSION}}")
    spec=$(echo "${spec//${inc_name}/${LIBDIR}}")
	spec=$(echo "${spec//${bin_src}/${REMORE_ZIP}}")

    echo "$spec" > "./build/pods/${spec_name}.podspec"
}

function main ()
{
	cp_product
	zip_product
	make_podsepc
	echo 'done.'
}

function usage ()
{
	echo "Usage:"
    echo "    $0 OpenSSL 1.1.1l"
	exit 1
}

VERSION="$2"

if [[ "x$VERSION" == 'x' ]];then
	usage
fi

case "$1" in
	'OpenSSL'|'openssl'|'OPENSSL')
		PODNAME='MROpenSSLPod'
		LIBDIR='openssl'
		main
	;;
	'fdk-aac'|'FDK-AAC')
		PODNAME='MRFDK-AACPod'
		LIBDIR='fdk-aac'
		main
	;;
	'lame'|'LAME')
		PODNAME='MRLamePod'
		LIBDIR='lame'
		main
	;;
	'x264'|'X264')
		PODNAME='MRX264Pod'
		LIBDIR='x264'
		main
	;;
	'ffmpeg'|'FFmpeg'|'FFMPEG')
		PODNAME='MRFFmpegPod'
		LIBDIR='ffmpeg'
		main
	;;
	*)
		usage
esac