# test library

`test.h` exports `void say(void)`, which prints the linked FFmpeg and libass
versions using `av_version_info()` and `ass_library_version()`.

The source is local; initialization does not clone a remote test repository.
For each platform (`ios`, `macos`, `tvos`, `android`, or `ohos`), run from the
repository root:

```sh
.github/workflows/install-dependencies.sh test macos
./main.sh init -l test -p macos
./main.sh compile -l test -p macos -c build
```

Replace `macos` with the target platform. Apple simulator architectures use the
same Apple build entry point. Outputs include `libtest.a`, `test.h`, and
`test.pc`. Link the application with test and its dependencies; when using
pkg-config for static linking, use `pkg-config --cflags --libs --static test`.
