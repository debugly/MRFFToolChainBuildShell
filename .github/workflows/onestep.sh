#!/bin/zsh

# https://stackoverflow.com/questions/4916492/git-describe-fails-with-fatal-no-names-found-cannot-describe-anything
# git describe --tags --always | awk -F . '{printf "RELEASE_VERSION=%s.%d",$1,$2+1}' | xargs > constants.env
# git describe --tags --always | awk -F - '{printf "RELEASE_VERSION=V1.0-%s",$NF}' | xargs > constants.env

set -e
set -o pipefail

export CONFIG_NAME=$1
export PLAT=$2
export MR_PLAT=$PLAT

if [[ -n $3 && "$3" == 'true' ]];then
    export DRYRUN=1 
else
    export DRYRUN=
fi

if [[ -n $4 && "$4" == 'true' ]];then
    export VERBOSE=1 
else
    export VERBOSE=
fi

export HOMEBREW_NO_AUTO_UPDATE=1
export RELEASE_DATE=$(TZ=UTC-8 date +'%y%m%d%H%M%S')

source ./configs/libs/${CONFIG_NAME}.sh
export RELEASE_VERSION=$GIT_REPO_VERSION
export TAG=${CONFIG_NAME}-${RELEASE_VERSION}-${RELEASE_DATE}

export TITLE="👏👏${CONFIG_NAME}-${PLAT}-${RELEASE_VERSION}"

ROOT_DIR=$PWD
DIST_DIR=$ROOT_DIR/build/dist
mkdir -p $DIST_DIR

function init_platform
{
    local plat=$1
    echo "---init $plat src--------------------------------------"
    ./main.sh init -p $plat -l ${CONFIG_NAME}
    
    echo "---generate src log--------------------------------------"
    cd build/src/$plat
    ls | awk -F ' ' '{printf "echo %s\n echo -------------\ngit -C %s log -n 1 | cat\n",$0,$0}' | bash > $DIST_DIR/$plat-compile-log-$RELEASE_VERSION.md
    cd $ROOT_DIR
}

function compile_ios_platform
{
    echo "---do compile ios libs--------------------------------------"

    local log_file="$DIST_DIR/ios-compile-log-$RELEASE_VERSION.md"

    if [[ $VERBOSE ]];then
        ./main.sh compile -p ios -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p ios -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi
         
    cd build/product/ios/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-ios-universal-${RELEASE_VERSION}.zip ./*
    
    cd ../universal-simulator
    zip -ryq $DIST_DIR/${LIB_NAME}-ios-universal-simulator-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_macos_platform
{
    echo "---do compile macos libs--------------------------------------"
    
    local log_file="$DIST_DIR/macos-compile-log-$RELEASE_VERSION.md"

    local extra_args=""

    if [[ $VERBOSE ]];then
        ./main.sh compile -p macos -c build -l ${CONFIG_NAME} $extra_args 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p macos -c build -l ${CONFIG_NAME} $extra_args >> "$log_file" 2>&1
    fi

    # Copy the architecture-specific binaries if they were compiled
    if [[ "$ENABLE_BIN" == "1" ]]; then
        mkdir -p build/product/macos/universal/${LIB_NAME}/bin
        for arch in arm64 x86_64; do
            local bin_dir="build/product/macos/${LIB_NAME}-${arch}/bin"
            if [ -d "$bin_dir" ]; then
                for bin_path in "$bin_dir"/*; do
                    if [ -f "$bin_path" ]; then
                        local bin=$(basename "$bin_path")
                        # 1. Copy to universal folder before zipping
                        cp "$bin_path" "build/product/macos/universal/${LIB_NAME}/bin/$bin-macos-${arch}"
                        echo "Copied $bin_path to build/product/macos/universal/${LIB_NAME}/bin/$bin-macos-${arch}"

                        # 2. Copy to release assets directory
                        cp "$bin_path" "$DIST_DIR/$bin-macos-${arch}"
                        echo "Copied $bin_path to $DIST_DIR/$bin-macos-${arch}"
                    fi
                done
            fi
        done
    fi

    cd build/product/macos/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-macos-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_tvos_platform
{
    echo "---do compile tvos libs--------------------------------------"

    local log_file="$DIST_DIR/android-compile-log-$RELEASE_VERSION.md"

    if [[ $VERBOSE ]];then
        ./main.sh compile -p tvos -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p tvos -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi     

    cd build/product/tvos/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-tvos-universal-${RELEASE_VERSION}.zip ./*
    
    cd ../universal-simulator
    zip -ryq $DIST_DIR/${LIB_NAME}-tvos-universal-simulator-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}


function compile_android_platform
{
    echo "---do compile android libs--------------------------------------"
    
    local log_file="$DIST_DIR/android-compile-log-$RELEASE_VERSION.md"
    
    if [[ $VERBOSE ]];then
        ./main.sh compile -p android -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p android -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi

    cd build/product/android/universal
    zip -ryq $DIST_DIR/${LIB_NAME}-android-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function make_xcfmwk_bundle()
{
    echo "---skip apple xcframework--------------------------------------"
    # echo "---Zip apple xcframework--------------------------------------"
    # cd build/product/xcframework
    # zip -ryq $DIST_DIR/${LIB_NAME}-apple-xcframework-${RELEASE_VERSION}.zip ./*
    # cd $ROOT_DIR
}

function replace_tag()
{
    local file=$1
    local key=$2

    # check PRE_COMPILE_TAG_IOS
    if grep -q "$key" "$file"; then
        # replace PRE_COMPILE_TAG_IOS=new_tag
        sed -i "" "s/^export $key=.*/export $key=$TAG/" $file
    else
        # PRE_COMPILE_TAG_IOS not found, append PRE_COMPILE_TAG_IOS
        [ -n "$(tail -c1 "$file")" ] && echo "" >> "$file"
        echo "export $key=$TAG" >> "$file"
    fi
}

function upgrade()
{
    local file="configs/libs/${CONFIG_NAME}.sh"
    case $PLAT in
        ios)
            replace_tag $file PRE_COMPILE_TAG_IOS
        ;;
        macos)
            replace_tag $file PRE_COMPILE_TAG_MACOS
        ;;
        tvos)
            replace_tag $file PRE_COMPILE_TAG_TVOS
        ;;
        apple)
            replace_tag $file PRE_COMPILE_TAG_IOS
            replace_tag $file PRE_COMPILE_TAG_MACOS
            replace_tag $file PRE_COMPILE_TAG_TVOS
        ;;
        android)
            replace_tag $file PRE_COMPILE_TAG_ANDROID
        ;;
        all)
            replace_tag $file PRE_COMPILE_TAG_IOS
            replace_tag $file PRE_COMPILE_TAG_MACOS
            replace_tag $file PRE_COMPILE_TAG_TVOS
            replace_tag $file PRE_COMPILE_TAG_ANDROID
        ;;
    esac

    git add $file
    git commit -m "upgrade $CONFIG_NAME to $TAG for $PLAT by cd"
    git pull --rebase
    git push origin
}

function publish()
{
    echo "---Create Release--------------------------------------"
    if [[ $DRYRUN ]];then
        echo "DRYRUN: gh release create $TAG -t $TITLE $DIST_DIR/*"
        return
    fi
    upgrade
    gh release create $TAG --target $(git branch --show-current) -t $TITLE $DIST_DIR/* --generate-notes
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

main