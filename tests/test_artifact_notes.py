#!/usr/bin/env python3
"""Release notes must report artifact architectures read from the actual packages."""
from pathlib import Path
import importlib.util
import json
import struct
import subprocess
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / '.github/workflows/artifact-notes.py'
ONESTEP = ROOT / '.github/workflows/onestep.sh'
TOOLCHAIN = ROOT / '.github/workflows/toolchain-notes.sh'

EM_386, EM_ARM, EM_X86_64, EM_AARCH64 = 3, 40, 62, 183
CPU_X86, CPU_ARM = 7, 12
CPU_X86_64 = 0x01000007
CPU_ARM64 = 0x0100000C
CPU_ARM64E = 0x0100000C


def module():
    if not SCRIPT.is_file():
        raise AssertionError('artifact note generator is missing')
    spec = importlib.util.spec_from_file_location('artifact_notes', SCRIPT)
    assert spec is not None and spec.loader is not None
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded


def elf(machine, bits=64):
    """Minimal ELF header with a real e_machine field."""
    if bits == 64:
        header = bytearray(64)
        header[0:4] = b'\x7fELF'
        header[4] = 2
        header[5] = 1
        struct.pack_into('<H', header, 18, machine)
    else:
        header = bytearray(52)
        header[0:4] = b'\x7fELF'
        header[4] = 1
        header[5] = 1
        struct.pack_into('<H', header, 18, machine)
    return bytes(header)


def macho(cputype, cpusubtype=0):
    return struct.pack('<IIiiII', 0xfeedfacf, cputype, cpusubtype, 2, 0, 0)


def fat_macho(cputypes):
    """Universal binary: big-endian header plus one entry per architecture."""
    header = struct.pack('>II', 0xcafebabe, len(cputypes))
    entries = b''.join(struct.pack('>IIIII', cpu, 0, 4096 * (i + 1), 64, 12)
                       for i, cpu in enumerate(cputypes))
    return header + entries + b'\x00' * 64


def ar_archive(objects):
    """Static library containing the given member blobs."""
    out = bytearray(b'!<arch>\n')
    for index, blob in enumerate(objects):
        name = f'member{index}.o'.ljust(16).encode()
        out += name
        out += b'0'.ljust(12) + b'0'.ljust(6) + b'0'.ljust(6)
        out += b'100644'.ljust(8) + str(len(blob)).encode().ljust(10) + b'`\n'
        out += blob
        if len(blob) % 2:
            out += b'\n'
    return bytes(out)


def make_zip(directory, name, members):
    path = Path(directory) / name
    with zipfile.ZipFile(path, 'w') as archive:
        for member, payload in members.items():
            archive.writestr(member, payload)
    return path


class PlatformMapping(unittest.TestCase):
    def test_android_uses_abi_directory_names(self):
        notes = module()
        self.assertEqual(notes.arch_name('aarch64', 'android'), 'arm64-v8a')
        self.assertEqual(notes.arch_name('arm', 'android'), 'armeabi-v7a')
        self.assertEqual(notes.arch_name('x86_64', 'android'), 'x86_64')
        self.assertEqual(notes.arch_name('x86', 'android'), 'x86')

    def test_non_android_platforms_use_short_names(self):
        notes = module()
        for platform in ('ohos', 'apple', 'ios', 'macos', 'tvos', 'all'):
            with self.subTest(platform=platform):
                self.assertEqual(notes.arch_name('aarch64', platform), 'arm64')
                self.assertEqual(notes.arch_name('x86_64', platform), 'x86_64')
                self.assertEqual(notes.arch_name('arm64e', platform), 'arm64e')


class BinaryDetection(unittest.TestCase):
    def test_elf_machines(self):
        notes = module()
        self.assertEqual(notes.detect(elf(EM_AARCH64)), 'aarch64')
        self.assertEqual(notes.detect(elf(EM_X86_64)), 'x86_64')
        self.assertEqual(notes.detect(elf(EM_ARM, bits=32)), 'arm')
        self.assertEqual(notes.detect(elf(EM_386, bits=32)), 'x86')

    def test_macho_thin_and_universal(self):
        notes = module()
        self.assertEqual(notes.detect(macho(CPU_ARM64)), 'arm64')
        self.assertEqual(notes.detect(macho(CPU_ARM64E, cpusubtype=2)), 'arm64e')
        self.assertEqual(notes.detect(macho(CPU_X86_64)), 'x86_64')
        self.assertEqual(sorted(notes.detect_all(fat_macho([CPU_ARM64, CPU_X86_64]))),
                         ['arm64', 'x86_64'])

    def test_static_archive_union(self):
        notes = module()
        blob = ar_archive([elf(EM_AARCH64), elf(EM_X86_64)])
        self.assertEqual(sorted(notes.detect_all(blob)), ['aarch64', 'x86_64'])

    def test_non_binaries_are_ignored(self):
        notes = module()
        self.assertEqual(notes.detect_all(b'prefix=/usr\n'), [])
        self.assertEqual(notes.detect_all(b''), [])


class Packaging(unittest.TestCase):
    def test_scan_zip_reads_real_member_layouts(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            path = make_zip(tmp, 'ffmpeg8-ohos-universal-8.1.2.zip', {
                'ffmpeg/ffmpeg-arm64/lib/libavcodec.a': ar_archive([elf(EM_AARCH64)]),
                'ffmpeg/ffmpeg-x86_64/lib/libavcodec.a': ar_archive([elf(EM_X86_64)]),
                'ffmpeg/ffmpeg-arm64/include/libffmpeg/config.h': b'#define CONFIG_X 1\n',
                'ffmpeg/ffmpeg-arm64/lib/pkgconfig/libavcodec.pc': b'prefix=/x\n',
            })
            self.assertEqual(notes.scan_zip(path, 'ohos'), ['arm64', 'x86_64'])

    def test_scan_zip_finds_apple_universal_member(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            path = make_zip(tmp, 'ass-ios-universal-0.17.5.zip', {
                'ass/lib/libass.a': fat_macho([CPU_ARM64, CPU_X86_64]),
            })
            self.assertEqual(notes.scan_zip(path, 'ios'), ['arm64', 'x86_64'])

    def test_scan_zip_reports_unknown_for_non_binaries(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            path = make_zip(tmp, 'bluray-ohos-universal-1.5.0.zip',
                            {'bluray/README': b'plain text\n'})
            self.assertEqual(notes.scan_zip(path, 'ohos'), [])

    def test_markdown_lists_every_archive(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            make_zip(tmp, 'ass-ohos-universal-0.17.5.zip',
                     {'ass/lib/libass.a': ar_archive([elf(EM_AARCH64)])})
            make_zip(tmp, 'ass-ios-universal-0.17.5.zip',
                     {'ass/lib/libass.a': fat_macho([CPU_ARM64, CPU_X86_64])})
            text = notes.markdown(tmp, 'all')
        self.assertIn('ass-ios-universal-0.17.5.zip', text)
        self.assertIn('ass-ohos-universal-0.17.5.zip', text)
        self.assertIn('arm64', text)

    def test_single_archive_uses_one_bullet(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            make_zip(tmp, 'ass-ohos-universal-0.17.5.zip',
                     {'ass/lib/libass.a': ar_archive([elf(EM_AARCH64), elf(EM_X86_64)])})
            text = notes.markdown(tmp, 'ohos')
        self.assertEqual(text, '- Architectures: arm64, x86_64\n')

    def test_no_heading_section(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            make_zip(tmp, 'ass-ohos-universal-0.17.5.zip',
                     {'ass/lib/libass.a': ar_archive([elf(EM_AARCH64)])})
            text = notes.markdown(tmp, 'ohos')
        self.assertNotIn('##', text)
        self.assertNotIn('Artifacts', text)

    def test_platform_is_inferred_per_archive(self):
        notes = module()
        self.assertEqual(notes.platform_of('ass-android-universal-0.17.5.zip'), 'android')
        self.assertEqual(notes.platform_of('ass-ios-universal-simulator-0.17.5.zip'), 'ios')
        self.assertEqual(notes.platform_of('ass-ohos-universal-0.17.5.zip'), 'ohos')
        with tempfile.TemporaryDirectory() as tmp:
            make_zip(tmp, 'ass-android-universal-0.17.5.zip',
                     {'ass/lib/libass.a': ar_archive([elf(EM_ARM, bits=32)])})
            make_zip(tmp, 'ass-ohos-universal-0.17.5.zip',
                     {'ass/lib/libass.a': ar_archive([elf(EM_AARCH64)])})
            text = notes.markdown(tmp, 'all')
        self.assertIn('armeabi-v7a', text)
        self.assertIn('ass-ohos-universal-0.17.5.zip`: arm64', text)

    def test_cli_prints_section(self):
        notes = module()
        with tempfile.TemporaryDirectory() as tmp:
            make_zip(tmp, 'ass-ohos-universal-0.17.5.zip',
                     {'ass/lib/libass.a': ar_archive([elf(EM_AARCH64), elf(EM_X86_64)])})
            result = subprocess.run(['python3', str(SCRIPT), tmp, 'ohos'],
                                    capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('arm64, x86_64', result.stdout)


class ReleaseNotesWiring(unittest.TestCase):
    def test_publish_appends_artifact_section(self):
        text = ONESTEP.read_text()
        publish = text[text.index('function publish()'):]
        publish = publish[:publish.index('\n}\n')]
        self.assertIn('artifact-notes.py', publish)

    def test_toolchain_notes_end_without_blank_gap(self):
        result = subprocess.run(['zsh', str(TOOLCHAIN), 'ohos'],
                                capture_output=True, text=True,
                                env={'PATH': '/usr/bin:/bin:/usr/sbin:/sbin'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(result.stdout.endswith('\n'))
        self.assertFalse(result.stdout.endswith('\n\n'))

    def test_toolchain_notes_drop_host_default_target(self):
        text = TOOLCHAIN.read_text()
        self.assertNotIn('InstalledDir', text)
        self.assertNotIn('--version', text)
        self.assertIn('productVersion', text)


if __name__ == '__main__':
    unittest.main()
