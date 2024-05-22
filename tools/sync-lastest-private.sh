#!/bin/sh
# sync lastest tag and master branch to private.

ffmpegRepo=https://github.com/bilibili/FFmpeg.git
libyuvRepo=https://github.com/lemenkov/libyuv.git
opensslRepo=https://github.com/openssl/openssl.git
opusRepo=https://gitlab.xiph.org/xiph/opus.git
blurayRepo=https://code.videolan.org/videolan/libbluray.git
dav1dRepo=https://code.videolan.org/videolan/dav1d.git

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

lib=$1

function update()
{
    local dir=$1
    cd "$dir"
    echo "pwd:$PWD"
    local url=$(git remote get-url github)
    
    if [[ -z $url ]]; then
        echo 'add github remote'
        eval repo='$'${dir}Repo
        echo "$repo"
        git remote add github "$repo"
    fi
    
    echo '=== will pull all from github ==='
    git reset --hard
    git checkout master -B master
    git pull origin master
    git fetch github --tags
    
    echo '=== will push all branch to private ==='
    git push origin --tags
    git push origin --all
    
    git remote remove github
    cd -
}

cd ../build/extra
if [[ -z "$lib" ]];then
    for lib in $(ls);
    do
        update "$lib"
    done;
else
    update "$lib"
fi



