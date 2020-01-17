#!/bin/sh

NAME='X264' #produt 里用的是小写的，这里使用首字母大写，因为操作系统不区分大小写，所以后续CP操作可以成功！
VERSION='20191217-2245'

MCB=${PWD}
PRODUCT="${MCB}/../product/${NAME}";
FAT_PRODUCT="$PRODUCT/${NAME}-$VERSION"
DEST="MR${NAME}Pod/MR${NAME}Pod/iOS"

if [[ -d "$FAT_PRODUCT" ]];then
	rm -rf "$DEST"
	mkdir -p "$DEST"
	cp -rf "$FAT_PRODUCT" "$DEST"
	echo 'done.'
fi