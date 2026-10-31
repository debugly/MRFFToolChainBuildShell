# OHOS Native SDK mirrors and CI host selection

## Pinned baseline

`ohos-sdk.json` is the single source of truth for the CI SDK version, API level,
per-host download URL, Native ZIP SHA256 and official source provenance.
All release-producing workflows use `.github/workflows/setup-ohos-sdk.py` when
the selected platform is `ohos` or `all`.

The baseline is **OpenHarmony 5.0.3.135 / API 15 Release** for both macOS hosts:

- `macos-26` / Apple Silicon: `darwin-arm64` Native SDK.
- `macos-26-intel` or `macos-15-intel`: `darwin-x86_64` Native SDK.

Host architecture is independent of the output ABI. Both SDKs contain the
AArch64 and x86_64 OHOS target sysroots used by this project. The installer
rejects unsupported hosts instead of silently invoking Rosetta or selecting a
package based on the OHOS target ABI.

This is an explicit build-SDK migration from the previous 5.0.0.71 / API 12
x64-only mirror. That older release and its assets are not overwritten. A new
SDK baseline does not, by itself, prove that new output runs on every API 12
device; minimum runtime compatibility requires separate artifact/device tests.

## Official provenance and redistribution notices

The [official 5.0.3 release notes](https://github.com/openharmony/docs/blob/OpenHarmony-5.0.3-Release/zh-cn/release-notes/OpenHarmony-v5.0.3-release.md)
list both Mac and Mac-M1 Public SDKs at 5.0.3.135 / API 15. Source TAR URLs,
upstream SHA256 values and exact Native ZIP members are recorded in the JSON.

Both complete official TARs were downloaded and SHA256-verified against their
upstream `.sha256` files. The original Native ZIP members were copied unchanged;
only their external asset filenames were normalized. There was no filtering,
recompression, compiler rebuilding or substitution with an installed local SDK.

Each archive retains its bundled licenses, `native/NOTICE.txt`, LLVM notices,
third-party notices and copyright statements. The two `native/NOTICE.txt` files
are byte-identical. The SDK is a multi-license distribution; this repository's
license does not replace those component terms.

Both Native metadata files identify the same version, API and Release type.
Compiler Mach-O CPU types were checked as ARM64 and x86_64 respectively. Of the
2,240 sysroot file entries, the only differing size/CRC pair is upstream's
`usr/lib/arm-linux-ohos/libc.a` (ARMv7, not supported by this project). All shared
headers and the supported AArch64/x86_64 sysroot entries match across hosts.

## Installer safety and local use

The installer verifies SHA256 before extraction, rejects path traversal and
escaping symlinks, preserves internal symlinks and executable permissions,
checks SDK/API metadata and the clang Mach-O host architecture, and runs
`clang --version`. It writes `OHOS_SDK_NATIVE` to `GITHUB_ENV` only after these
checks succeed. Each installation uses a new private directory under
`RUNNER_TEMP`; existing SDKs are not modified.

For an already downloaded archive, outside GitHub Actions:

```sh
mkdir -p "$TMPDIR/ohos-sdk-acceptance"
python3 .github/workflows/setup-ohos-sdk.py \
  --archive /path/to/native-darwin-arm64-5.0.3.135.zip \
  --work-dir "$TMPDIR/ohos-sdk-acceptance" \
  --env-file "$TMPDIR/ohos-sdk-acceptance/sdk.env"
. "$TMPDIR/ohos-sdk-acceptance/sdk.env"
```

The archive must match the host entry in `configs/ohos-sdk.json`; an Intel
archive is not accepted as the ARM64 archive, even if Rosetta is installed.

## Reproducible compile/link probe

The complete probe is committed at `tests/probes/ohos_sdk_smoke.c`. It references
both native media decoder and encoder APIs. After SDK installation:

```sh
for triple in aarch64-linux-ohos x86_64-linux-ohos; do
  "$OHOS_SDK_NATIVE/llvm/bin/clang" \
    --target="$triple" --sysroot="$OHOS_SDK_NATIVE/sysroot" \
    -shared -fPIC -Wl,--no-undefined \
    tests/probes/ohos_sdk_smoke.c \
    -lnative_media_vdec -lnative_media_venc \
    -lnative_media_codecbase -lnative_media_core \
    -o "$TMPDIR/libohos-sdk-smoke-$triple.so"
  "$OHOS_SDK_NATIVE/llvm/bin/llvm-readelf" -h \
    "$TMPDIR/libohos-sdk-smoke-$triple.so"
done
```

The official ARM64-host ZIP passed installation and both target links locally;
ELF Machine fields were AArch64 and AMD x86-64. These are cross-compilation and
link checks, not execution on a device or proof of hardware codec availability.

Run deterministic installer, archive-safety and workflow regression tests with:

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

At initial integration all 18 tests passed. Real macOS 26 ARM64/Intel CI
acceptance is tracked separately; a local macOS host test is not a substitute
for either runner's result. Test Release runs use `draft=true`, leaving
published consumer dependency pins unchanged.
