#!/bin/zsh

# Report the build OS and the SDK versions used for compilation.
# Host details (compiler default target, installed paths) are intentionally
# omitted: they describe the build machine, not the published artifacts.
# Artifact architectures come from .github/workflows/artifact-notes.py.
set -e
set -o pipefail

function note_version()
{
    local label=$1 value
    shift
    if value=$("$@" 2>/dev/null) && [[ -n "$value" ]]; then
        value=${value//$'\n'/; }
        printf -- '- %s: %s\n' "$label" "$value"
    else
        printf -- '- %s: unavailable\n' "$label"
    fi
}

printf '## Build toolchain\n\n'
if [[ $(uname -s) == Darwin ]]; then
    note_version 'macOS' sw_vers -productVersion
else
    note_version 'Build OS' uname -sr
fi
printf -- '- Target: %s\n' "$1"

case $1 in
    ios|macos|tvos|apple|all)
        note_version 'Xcode' xcodebuild -version
        local_sdks=()
        case $1 in
            ios) local_sdks=(iphoneos iphonesimulator) ;;
            macos) local_sdks=(macosx) ;;
            tvos) local_sdks=(appletvos appletvsimulator) ;;
            apple|all) local_sdks=(macosx iphoneos iphonesimulator appletvos appletvsimulator) ;;
        esac
        for sdk in "${local_sdks[@]}"; do
            note_version "$sdk SDK" xcrun --sdk "$sdk" --show-sdk-version
        done
        ;;
esac

case $1 in
    android|all)
        ndk_root=${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-${ANDROID_NDK:-}}}
        note_version 'Android NDK' awk -F '=' '/^Pkg.Revision[[:space:]]*=/ {gsub(/^[[:space:]]+|[[:space:]\r]+$/, "", $2); print $2; exit}' "$ndk_root/source.properties"
        ;;
esac

case $1 in
    ohos|all)
        native_root=${OHOS_SDK_NATIVE:-${OHOS_NATIVE_HOME:-}}
        if [[ -z "$native_root" && -n "$OHOS_SDK_HOME" ]]; then
            native_root=$(find "$OHOS_SDK_HOME" -maxdepth 3 -type d -name native -print -quit 2>/dev/null || true)
        fi
        note_version 'OHOS SDK' python3 -c 'import json, sys; d=json.load(open(sys.argv[1])); print(d["version"], "API " + str(d["apiVersion"]))' "$native_root/oh-uni-package.json"
        ;;
esac
printf '\n'
