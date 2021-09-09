#!/bin/sh

function cp_product
{
	name="$1"
	version="$2"
	local prodcut="build/universal/${name}";
	dest="../MakePod/MR${name}Pod/MR${name}Pod/macOS/${version}"

	if [[ -d "$prodcut" ]];then
		rm -rf "$dest"
		mkdir -p "$dest"
		cp -rf $prodcut/* "$dest"
		echo 'done.'
	fi
}

if [[ "x$1" != 'x' && "x$2" != 'x' ]];then
	cp_product "$1" "$2"
else
	echo "Usage:"
    echo "    $0 ffmpeg|openssl 4.4"
fi

