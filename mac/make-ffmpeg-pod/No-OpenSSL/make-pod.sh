#!/bin/sh

function cp_product
{
	name="$1"
	version="$2"
	local prodcut="../../build/universal/${name}"
	dest="./MR${name}Pod/macOS/${version}"

	if [[ -d "$prodcut" ]];then
		rm -rf "$dest"
		mkdir -p "$dest"
		cp -rf $prodcut/* "$dest"
		echo 'copy succ.'
	fi
}

if [[ "x$1" != 'x' ]];then
	cp_product 'FFmpeg' "$1"
	zip -ryq "MRFFmpegPod-macOS-${1}.zip" ./MRFFmpegPod
	echo 'zip done.'
else
	echo "Usage:"
    echo "    $0 4.4 [openssl]"
fi