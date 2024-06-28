#!/bin/zsh

# https://stackoverflow.com/questions/4916492/git-describe-fails-with-fatal-no-names-found-cannot-describe-anything
# git describe --tags --always | awk -F . '{printf "RELEASE_VERSION=%s.%d",$1,$2+1}' | xargs > constants.env
# git describe --tags --always | awk -F - '{printf "RELEASE_VERSION=V1.0-%s",$NF}' | xargs > constants.env

set -e

export LIB_NAME=$1
export PLAT=$2
export HOMEBREW_NO_AUTO_UPDATE=1
export RELEASE_DATE=$(TZ=UTC-8 date +'%y%m%d%H%M%S')
export RELEASE_VERSION=$(grep GIT_REPO_VERSION= ./configs/libs/${LIB_NAME}.sh | awk -F = '{printf "%s",$2}')
export TAG=${LIB_NAME}-${RELEASE_VERSION}-${RELEASE_DATE}
export TITLE="👏👏${LIB_NAME}-${RELEASE_VERSION}"

ROOT_DIR=$PWD
DIST_DIR=$ROOT_DIR/dist
mkdir -p $DIST_DIR

function init_platform
{
    local plat=$1
    echo "---init $plat src--------------------------------------"
    ./main.sh init -p $plat -l ${LIB_NAME}
    
    echo "---generate src log--------------------------------------"
    cd build/src/$plat
    ls | awk -F ' ' '{printf "echo %s\n echo -------------\ngit -C %s log -n 1 | cat\n",$0,$0}' | bash > $DIST_DIR/$plat-src-log-$RELEASE_VERSION.md
    cd $ROOT_DIR
}

function compile_ios_platform
{
    echo "---do compile ios libs--------------------------------------"
    ./main.sh compile -p ios -c build -l ${LIB_NAME}
    cd build/product/ios/universal
    zip -rq ios-universal.zip ./*
    mv ios-universal.zip $DIST_DIR/${LIB_NAME}-ios-universal-${RELEASE_VERSION}.zip
    
    cd ../universal-simulator
    zip -rq ios-universal-simulator.zip ./*
    mv ios-universal-simulator.zip $DIST_DIR/${LIB_NAME}-ios-universal-simulator-${RELEASE_VERSION}.zip
    cd $ROOT_DIR
}

function compile_macos_platform
{
    echo "---do compile macos libs--------------------------------------"
    ./main.sh compile -p macos -c build -l ${LIB_NAME}
    cd build/product/macos/universal
    zip -rq macos-universal.zip ./*
    mv macos-universal.zip $DIST_DIR/${LIB_NAME}-macos-universal-${RELEASE_VERSION}.zip
    cd $ROOT_DIR
}

function compile_tvos_platform
{
    echo "---do compile tvos libs--------------------------------------"
    ./main.sh compile -p tvos -c build -l ${LIB_NAME}
    cd build/product/tvos/universal
    zip -rq tvos-universal.zip ./*
    mv tvos-universal.zip $DIST_DIR/${LIB_NAME}-tvos-universal-${RELEASE_VERSION}.zip
    
    cd ../universal-simulator
    zip -rq tvos-universal-simulator.zip ./*
    mv tvos-universal-simulator.zip $DIST_DIR/${LIB_NAME}-tvos-universal-simulator-${RELEASE_VERSION}.zip
    cd $ROOT_DIR
}

function make_bundle()
{
    echo "---Zip apple xcframework--------------------------------------"
    cd build/product/xcframework
    zip -rq apple-xcframework.zip ./* && mv apple-xcframework.zip $DIST_DIR/${LIB_NAME}-apple-xcframework-${RELEASE_VERSION}.zip && cd - >/dev/null
    cd $ROOT_DIR
    
    echo "---Create Release--------------------------------------"
    gh release create $TAG -p -t $TITLE $DIST_DIR/*.*
}

case $PLAT in
    ios)
        init_platform $PLAT
        compile_ios_platform
        make_bundle
    ;;
    macos)
        init_platform $PLAT
        compile_macos_platform
        make_bundle
    ;;
    tvos)
        init_platform $PLAT
        compile_tvos_platform
        make_bundle
    ;;
    all)
        init_platform ios
        init_platform macos
        init_platform tvos
        compile_ios_platform
        compile_macos_platform
        compile_tvos_platform
        make_bundle
    ;;
esac
