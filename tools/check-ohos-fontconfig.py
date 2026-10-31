#!/usr/bin/env python3
"""Fail closed if an OHOS fontconfig package carries host gettext linkage."""
import argparse
from pathlib import Path
import sys
import re
import subprocess


def check(prefix, nm):
    pc = prefix / 'lib/pkgconfig/fontconfig.pc'
    text = pc.read_text()
    if 'libintl' in text or '-lintl' in text:
        raise ValueError(f'{pc}: forbidden libintl dependency')
    variables = dict(re.findall(r'^([\w]+)=(.*)$', text, re.MULTILINE))
    # Relocatable paths under this target prefix are legitimate; host library
    # paths, including those hidden behind a pc variable, are not.
    for line in text.splitlines():
        if '=' in line and (':' not in line or line.index('=') < line.index(':')):
            value = line.split('=', 1)[1]
        elif line.startswith(('Libs:', 'Libs.private:', 'Cflags:', 'Cflags.private:')):
            value = line.split(':', 1)[1]
        else:
            continue
        for _ in range(32):
            expanded = re.sub(r'\$\{(\w+)\}', lambda m: variables.get(m[1], m[0]), value)
            if expanded == value:
                break
            value = expanded
        if '${' in value:
            raise ValueError(f'{pc}: unresolved pc variable in {line}')
        for path in re.findall(r'/[^\s,;]+', value):
            if not Path(path).resolve().is_relative_to(prefix.resolve()):
                raise ValueError(f'{pc}: forbidden absolute host path: {path}')
    archive = prefix / 'lib/libfontconfig.a'
    symbols = subprocess.run([nm, '-g', str(archive)], check=True,
                             capture_output=True, text=True).stdout
    forbidden = re.search(r'\b_?(?:libintl_\w+|(?:d|dc|n|dn|dcn)?gettext|(?:bind_?textdomain(?:_codeset)?|textdomain))\b', symbols)
    if forbidden:
        raise ValueError(f'{archive}: forbidden NLS symbol: {forbidden[0]}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prefix', required=True, type=Path)
    parser.add_argument('--nm', required=True)
    args = parser.parse_args()
    try:
        check(args.prefix, args.nm)
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
