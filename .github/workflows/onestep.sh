#!/bin/zsh

# https://stackoverflow.com/questions/4916492/git-describe-fails-with-fatal-no-names-found-cannot-describe-anything
# git describe --tags --always | awk -F . '{printf "RELEASE_VERSION=%s.%d",$1,$2+1}' | xargs > constants.env
# git describe --tags --always | awk -F - '{printf "RELEASE_VERSION=V1.0-%s",$NF}' | xargs > constants.env

set -e

export LIB_NAME=$1
export PLAT=$2
export HOMEBREW_NO_AUTO_UPDATE=1
export RELEASE_DATE=$(TZ=UTC-8 date +'%y%m%d%H%M%S')
export RELEASE_VERSION=$(grep GIT_REPO_VERSION= ./configs/libs/${LIB_NAME}.sh | tail -n 1 | awk -F = '{printf "%s",$2}')
export TAG=${LIB_NAME}-${RELEASE_VERSION}-${RELEASE_DATE}
export TITLE="👏👏${LIB_NAME}-${RELEASE_VERSION}"

ROOT_DIR=$PWD
DIST_DIR=$ROOT_DIR/build/dist
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
    zip -ryq $DIST_DIR/${LIB_NAME}-ios-universal-${RELEASE_VERSION}.zip ./*
    
    cd ../universal-simulator
    zip -ryq $DIST_DIR/${LIB_NAME}-ios-universal-simulator-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_macos_platform
{
    echo "---do compile macos libs--------------------------------------"
    ./main.sh compile -p macos -c build -l ${LIB_NAME}
    cd build/product/macos/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-macos-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_tvos_platform
{
    echo "---do compile tvos libs--------------------------------------"
    ./main.sh compile -p tvos -c build -l ${LIB_NAME}
    cd build/product/tvos/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-tvos-universal-${RELEASE_VERSION}.zip ./*
    
    cd ../universal-simulator
    zip -ryq $DIST_DIR/${LIB_NAME}-tvos-universal-simulator-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}


function compile_android_platform
{
    echo "---do compile android libs--------------------------------------"
    ./main.sh compile -p android -c build -l ${LIB_NAME}
    cd build/product/android/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-android-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function make_xcfmwk_bundle()
{
    echo "---Zip apple xcframework--------------------------------------"
    cd build/product/xcframework
    zip -ryq $DIST_DIR/${LIB_NAME}-apple-xcframework-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function upgrade()
{
    file="configs/libs/${LIB_NAME}.sh"
    sed -i "" "s/^export PRE_COMPILE_TAG=.*/export PRE_COMPILE_TAG=$TAG/" $file
    git add $file
    git commit -m "upgrade $LIB_NAME to $TAG by cd"
    git pull --rebase
    git push origin
}

function publish()
{
    echo "---Create Release--------------------------------------"
    upgrade
    gh release create $TAG -t $TITLE $DIST_DIR/*.*
}

function main()
{
    case $PLAT in
        ios)
            init_platform $PLAT
            compile_ios_platform
            make_xcfmwk_bundle
            publish
        ;;
        macos)
            init_platform $PLAT
            compile_macos_platform
            make_xcfmwk_bundle
            publish
        ;;
        tvos)
            init_platform $PLAT
            compile_tvos_platform
            make_xcfmwk_bundle
            publish
        ;;
        apple)
            init_platform ios
            compile_ios_platform
            init_platform macos
            compile_macos_platform
            init_platform tvos
            compile_tvos_platform
            make_xcfmwk_bundle
            publish
        ;;
        android)
            init_platform $PLAT
            compile_android_platform
            publish
        ;;
        all)
            init_platform ios
            compile_ios_platform
            init_platform macos
            compile_macos_platform
            init_platform tvos
            compile_tvos_platform
            make_xcfmwk_bundle

            init_platform android
            compile_android_platform

            publish
        ;;
    esac
    
}

if [[ $LIB_NAME == 'test' ]];then
    echo "test" > $DIST_DIR/test.md
    publish
else
    main
fi