#!/bin/sh

function cp_product
{
	name="$1"
	version="$2"
	local prodcut="../build/universal/${name}"
	dest="./MR${name}Pod/iOS/${version}"

	if [[ -d "$prodcut" ]];then
		rm -rf "$dest"
		mkdir -p "$dest"
		cp -rf $prodcut/* "$dest"
	fi
}

if [[ "x$1" != 'x' ]];then
	cp_product 'OpenSSL' "$1"
	zip -ryq "MROpenSSLPod-iOS-${1}.zip" ./MROpenSSLPod
	echo 'done.'
else
	echo "Usage:"
    echo "    $0 1.1.1l"
fi