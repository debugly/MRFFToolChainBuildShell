# OHOS fontconfig: keep host gettext out of static packages

## Root cause and supported switch

The pinned fontconfig **2.18.3** tag resolves to
`0f236723a3c26bd9745e32ba2b3ee21e5f809295` (verified against the upstream
GitLab tag as well as the source checkout). Its `meson.options:8-9` declares
`nls` as a **feature**, defaulting to `auto`; use **`-Dnls=disabled`**, not a
boolean or an Autotools option. `meson.build:229-236` passes that feature to
`dependency('intl')` and adds the result to the library dependencies.

With `auto`, a cross compiler exposed to host gettext headers/libraries can
produce a target archive referencing `libintl_dgettext` and pc metadata naming
host intl. Deleting `Libs.private` after compilation would leave that undefined
symbol behind; disabling NLS before compilation removes both causes.

`do-compile/ohos/fontconfig.sh` disables NLS and runs
`tools/check-ohos-fontconfig.py` after installation. The check rejects intl in
pc metadata, absolute paths outside the target prefix (including pc-variable
indirection and directory traversal), and defined **or** undefined gettext /
libintl / textdomain symbols in `libfontconfig.a`. Paths under the target
installation prefix are expected, not host pollution. Missing inputs or an
unusable nm fail the build. The symbol check uses the SDK's `MR_NM`.

## Regression tests

```sh
export TMPDIR=/Users/matt/.hermes/cache/scratch
python3 -m unittest discover -s tests -v
```

The tests execute the actual recipe with an intercepted Meson entry point and
compile real small archives for the symbol checks. Each new rejection was
observed RED before implementation: missing NLS flag, accepted polluted pc,
accepted host paths, accepted defined/undefined gettext symbols, and accepted
prefix-escaping paths. Clean relocatable metadata and fail-closed missing
archive/tool behavior are covered too.

## Local acceptance (2026-10-31)

- Base: `a94244ba`; macOS ARM64 host; SDK **5.0.3.135 / API 15**, clang **15.0.4**.
- Fontconfig source: tag/commit above. libass **0.17.5**:
  `4a05d8127f525943ebf45fdc6497c9e665947f0d`.
- The installed Meson 1.7.0 genuinely rejected this fontconfig source, which
  requires **>= 1.11.0**. Meson 1.11.0 source
  (`6ac66b9cbe36e861a4b10cf62d75ec181dfb291a`) was run directly from this
  worktree's ignored `build/meson-source/`, using an already installed Python.
  No host package was installed/upgraded, no source version guard was patched,
  and no SDK was copied.
- Cross files deliberately exposed existing host gettext with
  `-I/opt/homebrew/opt/gettext/include` and
  `-L/opt/homebrew/opt/gettext/lib`. Target dependency pc files/archives were
  read-only reused from the original worktree; sources/products/logs were
  created only in this worktree.
- **Real RED:** the unchanged `auto` configuration built an arm64 archive with
  `U libintl_dgettext`, `#define ENABLE_NLS 1`, and pc `-lintl`. Its libass
  renderer link exited 1: host `libintl.a` members were not ELF/LLVM bitcode,
  followed by `undefined symbol: libintl_dgettext` from `fccfg.c`. This is the
  ARM-host `/opt/homebrew` equivalent of the Intel CI `/usr/local` failure.
- **Real GREEN:** the actual fontconfig and libass OHOS compile scripts built
  and installed **arm64 and x86_64**. Both fontconfig Meson introspection files
  report `nls=disabled`, both summaries report `NLS: NO`, both package checks
  pass, and both libass renderer executables link. In addition, every member
  of each new fontconfig archive links into an ELF shared object with
  `--whole-archive -z defs` (no undefined symbols allowed).
- The complete regression suite passed **15 tests**. `bash -n` and
  `git diff --check` passed. Meson reported an upstream `preprocessor_0 has no
  sources` warning; it did not prevent either ABI from building/linking.

Ignored local evidence: `build/evidence/{arm64,x86_64}/build.log`,
`ass-build.log`, `intro-buildoptions.json`, `whole-link.log`, ELF renderer and
whole-archive outputs; baseline evidence: `build/evidence/baseline-auto-*.log`,
`baseline-ass-link.log`, and `build/product/baseline-auto/`.
The build drivers remain at `build/run-probe.py` and `build/run-ass-probe.py`.
These are local evidence, not required installed tooling.

## Repeat the package and full-archive link checks

After building both libraries, set `OHOS_SDK_NATIVE`, `TARGET_DEPS` (a directory
containing `freetype/freetype-arm64`, `xml2/xml2-arm64`, etc.), and optionally
`LOCAL_PRODUCTS` (defaults to this validation's `build/product`). The renderer
smoke source and its compile/link command are permanently maintained in
`do-compile/ohos/ass.sh:45-63`; that script already cross-links it after build.
The independent full-fontconfig-archive check is:

```sh
set -eu
: "${OHOS_SDK_NATIVE:?set the SDK native directory}"
: "${TARGET_DEPS:?set the read-only target dependency root}"
LOCAL_PRODUCTS=${LOCAL_PRODUCTS:-"$PWD/build/product"}
EVIDENCE_DIR=${EVIDENCE_DIR:-"$PWD/build/evidence/documented"}
mkdir -p "$EVIDENCE_DIR"
export PKG_CONFIG_PATH=
for arch in arm64 x86_64; do
    case "$arch" in
        arm64) triple=aarch64-linux-ohos ;;
        x86_64) triple=x86_64-linux-ohos ;;
    esac
    fc="$LOCAL_PRODUCTS/fontconfig-$arch"
    ass="$LOCAL_PRODUCTS/ass-$arch"
    export PKG_CONFIG_LIBDIR="$ass/lib/pkgconfig:$fc/lib/pkgconfig"
    for lib in freetype xml2 harfbuzz fribidi unibreak; do
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR:$TARGET_DEPS/$lib/$lib-$arch/lib/pkgconfig"
    done
    python3 tools/check-ohos-fontconfig.py --prefix "$fc" \
        --nm "$OHOS_SDK_NATIVE/llvm/bin/llvm-nm"
    "$OHOS_SDK_NATIVE/llvm/bin/clang++" --target="$triple" \
        --sysroot="$OHOS_SDK_NATIVE/sysroot" -shared -Wl,-z,defs \
        -Wl,--whole-archive "$fc/lib/libfontconfig.a" -Wl,--no-whole-archive \
        -o "$EVIDENCE_DIR/fontconfig-$arch.so" $(pkg-config --libs --static libass)
    "$OHOS_SDK_NATIVE/llvm/bin/llvm-readelf" -h "$EVIDENCE_DIR/fontconfig-$arch.so"
done
```

This verifies compile/link integrity, **not device runtime, font discovery, or
subtitle rendering**. FFmpeg was not rebuilt in this focused fix. CI, published
packages and dependency pins remain unchanged; no commit/push/release/dispatch
was performed. Existing consumers still need a separately authorized ordered
fontconfig → libass → FFmpeg rebuild/publication before this fix reaches them.
