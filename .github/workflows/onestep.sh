#!/bin/zsh

# https://stackoverflow.com/questions/4916492/git-describe-fails-with-fatal-no-names-found-cannot-describe-anything
# git describe --tags --always | awk -F . '{printf "RELEASE_VERSION=%s.%d",$1,$2+1}' | xargs > constants.env
# git describe --tags --always | awk -F - '{printf "RELEASE_VERSION=V1.0-%s",$NF}' | xargs > constants.env

set -e
set -o pipefail

CONFIG_FILE="./configs/libs/${1}.sh"
if [[ -L "$CONFIG_FILE" ]]; then
    REAL_CONFIG_FILE=$(realpath "$CONFIG_FILE")
    CONFIG_BASE=$(basename "$REAL_CONFIG_FILE")
    export CONFIG_NAME="${CONFIG_BASE%.sh}"
else
    export CONFIG_NAME=$1
fi
export PLAT=$2
export MR_PLAT=$PLAT

if [[ -n $3 && "$3" == 'true' ]];then
    export DRAFT=1
else
    export DRAFT=
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

# Capture versions before compilation and upgrade can change config tags.
RELEASE_NOTES_FILE="$ROOT_DIR/build/${CONFIG_NAME}-${PLAT}-release-notes.md"
function generate_dependency_notes()
{
    local platforms
    case $PLAT in
        all) platforms=(ios macos tvos android ohos) ;;
        apple) platforms=(ios macos tvos) ;;
        *) platforms=("$PLAT") ;;
    esac

    local platform label records dependency_platform dependency tag key
    records=$(zsh .github/workflows/install-dependencies.sh "$CONFIG_NAME" "$PLAT" --list)
    : > "$RELEASE_NOTES_FILE"
    for platform in "${platforms[@]}"; do
        local heading_written=0
        while read -r dependency_platform dependency; do
            [[ -n "$dependency" && "$dependency_platform" == "$platform" ]] || continue
            key="PRE_COMPILE_TAG_${(U)platform}"
            tag=$(
                unset "$key"
                source "./configs/libs/${dependency}.sh"
                print -r -- "${(P)key}"
            )
            if [[ -z "$tag" ]]; then
                echo "Missing $key in configs/libs/${dependency}.sh" >&2
            fi
            if (( ! heading_written )); then
                case $platform in
                    ios) label=iOS ;;
                    macos) label=macOS ;;
                    tvos) label=tvOS ;;
                    android) label=Android ;;
                    ohos) label=OHOS ;;
                    *) label=$platform ;;
                esac
                printf '%s %s deps:\n' "$label" "$CONFIG_NAME" >> "$RELEASE_NOTES_FILE"
                heading_written=1
            fi
            if [[ -z "$tag" ]]; then
                printf -- '- %s (%s is not configured)\n' "$dependency" "$key" >> "$RELEASE_NOTES_FILE"
                continue
            fi
            printf -- '- [%s](https://github.com/debugly/MRFFToolChainBuildShell/releases/tag/%s)\n' "$tag" "$tag" >> "$RELEASE_NOTES_FILE"
        done <<< "$records"
        if (( heading_written )); then
            printf '\n' >> "$RELEASE_NOTES_FILE"
        fi
    done
}

generate_dependency_notes
zsh .github/workflows/toolchain-notes.sh "$PLAT" >> "$RELEASE_NOTES_FILE"

function init_platform
{
    local plat=$1
    echo "---init $plat src--------------------------------------"
    ./main.sh init -p $plat -l ${CONFIG_NAME}
    
    echo "---generate src log--------------------------------------"
    cd build/src/$plat
    ls | awk -F ' ' '{printf "echo %s\n echo -------------\ngit -C %s log -n 1 | cat\n",$0,$0}' | bash > $DIST_DIR/$plat-compile-log-$RELEASE_VERSION.log
    cd $ROOT_DIR
}

function compile_ios_platform
{
    echo "---do compile ios libs--------------------------------------"

    local log_file="$DIST_DIR/ios-compile-log-$RELEASE_VERSION.log"

    if [[ $VERBOSE ]];then
        ./main.sh compile -p ios -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p ios -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi
         
    cd build/product/ios/universal
    zip -ryq $DIST_DIR/${CONFIG_NAME}-ios-universal-${RELEASE_VERSION}.zip ./*
    
    cd ../universal-simulator
    zip -ryq $DIST_DIR/${CONFIG_NAME}-ios-universal-simulator-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_macos_platform
{
    echo "---do compile macos libs--------------------------------------"
    
    local log_file="$DIST_DIR/macos-compile-log-$RELEASE_VERSION.log"

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
    zip -ryq $DIST_DIR/${CONFIG_NAME}-macos-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_tvos_platform
{
    echo "---do compile tvos libs--------------------------------------"

    local log_file="$DIST_DIR/tvos-compile-log-$RELEASE_VERSION.log"

    if [[ $VERBOSE ]];then
        ./main.sh compile -p tvos -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p tvos -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi     

    cd build/product/tvos/universal
    zip -ryq $DIST_DIR/${CONFIG_NAME}-tvos-universal-${RELEASE_VERSION}.zip ./*
    
    cd ../universal-simulator
    zip -ryq $DIST_DIR/${CONFIG_NAME}-tvos-universal-simulator-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}


function compile_android_platform
{
    echo "---do compile android libs--------------------------------------"
    
    local log_file="$DIST_DIR/android-compile-log-$RELEASE_VERSION.log"
    
    if [[ $VERBOSE ]];then
        ./main.sh compile -p android -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p android -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi

    cd build/product/android/universal
    zip -ryq $DIST_DIR/${CONFIG_NAME}-android-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function compile_ohos_platform
{
    echo "---do compile ohos libs--------------------------------------"
    
    local log_file="$DIST_DIR/ohos-compile-log-$RELEASE_VERSION.log"
    
    if [[ $VERBOSE ]];then
        ./main.sh compile -p ohos -c build -l ${CONFIG_NAME} 2>&1 | tee -a "$log_file"
    else
        ./main.sh compile -p ohos -c build -l ${CONFIG_NAME} >> "$log_file" 2>&1
    fi

    cd build/product/ohos/universal
    zip -ryq $DIST_DIR/${CONFIG_NAME}-ohos-universal-${RELEASE_VERSION}.zip ./*
    cd $ROOT_DIR
}

function make_xcfmwk_bundle()
{
    echo "---skip apple xcframework--------------------------------------"
    # echo "---Zip apple xcframework--------------------------------------"
    # cd build/product/xcframework
    # zip -ryq $DIST_DIR/${CONFIG_NAME}-apple-xcframework-${RELEASE_VERSION}.zip ./*
    # cd $ROOT_DIR
}

function replace_tag()
{
    local file=$1
    if [ -L "$file" ]; then
        file=$(realpath "$file")
    fi
    local key=$2

    # check PRE_COMPILE_TAG_IOS
    if grep -q "$key" "$file"; then
        # replace PRE_COMPILE_TAG_IOS=new_tag
        sed -i "" "s/^export $key=.*/export $key=$TAG/" "$file"
    else
        # PRE_COMPILE_TAG_IOS not found, append PRE_COMPILE_TAG_IOS
        [ -n "$(tail -c1 "$file")" ] && echo "" >> "$file"
        echo "export $key=$TAG" >> "$file"
    fi
}

function upgrade()
{
    local file="configs/libs/${CONFIG_NAME}.sh"
    if [ -L "$file" ]; then
        file=$(realpath "$file")
    fi
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
        ohos)
            replace_tag $file PRE_COMPILE_TAG_OHOS
        ;;
        all)
            replace_tag $file PRE_COMPILE_TAG_IOS
            replace_tag $file PRE_COMPILE_TAG_MACOS
            replace_tag $file PRE_COMPILE_TAG_TVOS
            replace_tag $file PRE_COMPILE_TAG_ANDROID
            replace_tag $file PRE_COMPILE_TAG_OHOS
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
    local release_args=()
    if [[ $DRAFT ]]; then
        release_args+=(--draft)
    else
        upgrade
    fi
    local target_commit=$(git rev-parse HEAD)
    local changelog
    changelog=$(gh api --method POST 'repos/{owner}/{repo}/releases/generate-notes' \
        -f tag_name="$TAG" -f target_commitish="$target_commit" --jq '.body')
    local combined_notes_file="${RELEASE_NOTES_FILE%.md}-with-changelog.md"
    {
        cat "$RELEASE_NOTES_FILE"
        printf '\n## Changelog\n\n%s\n' "$changelog"
    } > "$combined_notes_file"
    gh release create "$TAG" --target "$target_commit" -t "$TITLE" $DIST_DIR/* --notes-file "$combined_notes_file" "${release_args[@]}"
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
        ohos)
            init_platform $PLAT
            compile_ohos_platform
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

            init_platform ohos
            compile_ohos_platform

            publish
        ;;
    esac
}

main