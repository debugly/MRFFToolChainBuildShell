#!/usr/bin/env python3
"""Report the architectures actually contained in published release archives.

Host details are deliberately excluded: a compiler's default target says nothing
about the target ABI of the packaged binaries. Architectures are read from the
ELF/Mach-O headers of the files inside each ZIP.
"""
import argparse
import struct
import sys
import zipfile
from pathlib import Path

ELF_MAGIC = b'\x7fELF'
AR_MAGIC = b'!<arch>\n'

ELF_MACHINES = {
    3: 'x86',
    8: 'mips',
    20: 'ppc',
    21: 'ppc64',
    40: 'arm',
    62: 'x86_64',
    183: 'aarch64',
}

MACHO_CPUS = {
    7: 'x86',
    12: 'arm',
    0x01000007: 'x86_64',
    0x0100000C: 'arm64',
}

# arm64e shares CPU_TYPE_ARM64 and is identified by its CPU subtype.
CPU_SUBTYPE_ARM64E = 2

ANDROID_NAMES = {
    'aarch64': 'arm64-v8a',
    'arm': 'armeabi-v7a',
    'x86_64': 'x86_64',
    'x86': 'x86',
}


def arch_name(arch, platform):
    """Map a detected architecture to the platform's published ABI name."""
    if platform == 'android':
        return ANDROID_NAMES.get(arch, arch)
    if arch == 'aarch64':
        return 'arm64'
    if arch == 'arm':
        return 'armv7'
    return arch


def _macho_archs(data):
    """Architectures of a thin or universal Mach-O file."""
    found = []
    if len(data) < 8:
        return found
    magic_be, magic_le = struct.unpack('>I', data[:4])[0], struct.unpack('<I', data[:4])[0]
    if magic_be in (0xcafebabe, 0xcafebabf):
        # Universal binary: big-endian fat header, 20-byte (fat) or 32-byte (fat64) entries.
        count = struct.unpack('>I', data[4:8])[0]
        stride = 32 if magic_be == 0xcafebabf else 20
        if count > 64:
            return found
        for index in range(count):
            start = 8 + index * stride
            if start + 8 > len(data):
                break
            cputype, cpusubtype = struct.unpack('>Ii', data[start:start + 8])
            found.append(_macho_name(cputype, cpusubtype & 0x00FFFFFF))
        return found
    for magic, layout in ((0xfeedfacf, '<'), (0xfeedface, '<'), (0xcffaedfe, '>'), (0xcefaedfe, '>')):
        if magic_le != magic and magic_be != magic:
            continue
        if len(data) < 12:
            return found
        cputype, cpusubtype = struct.unpack(layout + 'Ii', data[4:12])
        return [_macho_name(cputype, cpusubtype & 0x00FFFFFF)]
    return found


def _macho_name(cputype, cpusubtype):
    if cputype == 0x0100000C and cpusubtype == CPU_SUBTYPE_ARM64E:
        return 'arm64e'
    return MACHO_CPUS.get(cputype, f'cpu{cputype:#x}')


def _elf_arch(data):
    if len(data) < 20:
        return None
    endian = '<' if data[5] == 1 else '>'
    return ELF_MACHINES.get(struct.unpack_from(endian + 'H', data, 18)[0])


def _ar_archs(data):
    """Union of member architectures in a static library."""
    found = []
    offset = len(AR_MAGIC)
    while offset + 60 <= len(data):
        header = data[offset:offset + 60]
        if header[58:60] != b'`\n':
            break
        try:
            size = int(header[48:58].strip() or b'0')
        except ValueError:
            break
        body = data[offset + 60:offset + 60 + size]
        found.extend(detect_all(body))
        offset += 60 + size + (size % 2)
    return found


def detect_all(data):
    """Every architecture exposed by one file's headers."""
    if data.startswith(ELF_MAGIC):
        arch = _elf_arch(data)
        return [arch] if arch else []
    if data.startswith(AR_MAGIC):
        return _ar_archs(data)
    return _macho_archs(data)


def detect(data):
    """Single architecture of a binary (first one found)."""
    found = detect_all(data)
    return found[0] if found else None


def scan_zip(path, platform='all'):
    """Architectures present in one release archive, in stable order."""
    found = set()
    try:
        with zipfile.ZipFile(path) as archive:
            for info in archive.infolist():
                if info.is_dir():
                    continue
                with archive.open(info) as member:
                    # Only headers are needed; static archives are read whole.
                    data = member.read() if info.filename.endswith('.a') else member.read(4096)
                for arch in detect_all(data):
                    found.add(arch_name(arch, platform))
    except (OSError, zipfile.BadZipFile, struct.error):
        return []
    return sorted(found)


def markdown(directory, platform='all'):
    """Release-note section describing every archive in the distribution directory."""
    archives = sorted(p for p in Path(directory).glob('*.zip'))
    lines = ['## Artifacts', '']
    if not archives:
        lines.append('- none')
        return '\n'.join(lines) + '\n'
    for archive in archives:
        archs = scan_zip(archive, platform)
        lines.append(f'- `{archive.name}`: ' + (', '.join(archs) if archs else 'unknown'))
    return '\n'.join(lines) + '\n'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path, help='directory holding release archives')
    parser.add_argument('platform', nargs='?', default='all',
                        help='target platform, used for ABI naming (android, ohos, apple, all)')
    args = parser.parse_args(argv)
    if not args.directory.is_dir():
        print(f'artifact notes: {args.directory} is not a directory', file=sys.stderr)
        return 1
    print(markdown(args.directory, args.platform), end='')
    return 0


if __name__ == '__main__':
    sys.exit(main())
