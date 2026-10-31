#!/usr/bin/env python3
"""OHOS fontconfig must not auto-detect the build host's gettext."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class FontconfigArtifact(unittest.TestCase):
    def test_accepts_clean_relocatable_package(self):
        with tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR')) as directory:
            prefix = Path(directory)
            pc = prefix / 'lib/pkgconfig/fontconfig.pc'
            pc.parent.mkdir(parents=True)
            pc.write_text(f'prefix={prefix}\nlibdir=${{prefix}}/lib\nincludedir=${{prefix}}/include\n'
                          'Libs: -L${libdir} -lfontconfig -pthread -lm\nCflags: -I${includedir}\n')
            source = prefix / 'probe.c'
            source.write_text('int fontconfig_probe(void) { return 0; }')
            subprocess.run(['cc', '-c', str(source), '-o', str(prefix / 'probe.o')], check=True)
            subprocess.run(['ar', 'rcs', str(prefix / 'lib/libfontconfig.a'), str(prefix / 'probe.o')], check=True)
            command = ['python3', str(ROOT / 'tools/check-ohos-fontconfig.py'),
                       '--prefix', str(prefix), '--nm', 'nm']
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            # A missing inspection tool or archive must never become success.
            result = subprocess.run(command[:-1] + ['missing-nm-tool'], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            (prefix / 'lib/libfontconfig.a').unlink()
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)

    def test_rejects_gettext_symbols_in_archive(self):
        for symbol in ['libintl_dgettext', 'dgettext', 'bindtextdomain']:
            for defined in [False, True]:
                with self.subTest(symbol=symbol, defined=defined), tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR')) as directory:
                    prefix = Path(directory)
                    pc = prefix / 'lib/pkgconfig/fontconfig.pc'
                    pc.parent.mkdir(parents=True)
                    pc.write_text('Libs: -lfontconfig\n')
                    source = prefix / 'probe.c'
                    source.write_text('int ' + symbol + '(void) { return 0; }' if defined else
                                      'extern int ' + symbol + '(void); int probe(void) { return ' + symbol + '(); }')
                    subprocess.run(['cc', '-c', str(source), '-o', str(prefix / 'probe.o')], check=True)
                    subprocess.run(['ar', 'rcs', str(prefix / 'lib/libfontconfig.a'), str(prefix / 'probe.o')], check=True)
                    result = subprocess.run(['python3', str(ROOT / 'tools/check-ohos-fontconfig.py'),
                                             '--prefix', str(prefix), '--nm', 'nm'],
                                            capture_output=True, text=True)
                    self.assertNotEqual(result.returncode, 0, symbol)
                    self.assertIn(symbol, result.stderr)

    def test_rejects_host_absolute_paths_in_pc(self):
        for line in ['Libs.private: /opt/homebrew/lib/libfoo.a',
                     'Libs.private: -L/usr/local/lib -lfoo',
                     'Cflags: -I/Applications/HostSDK/include',
                     'hostlib=/Users/runner/host/libfoo.a\nLibs.private: ${hostlib}',
                     'hostlib=/opt/homebrew/lib\nLibs.private: -L${hostlib} -lfoo']:
            with self.subTest(line=line), tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR')) as directory:
                prefix = Path(directory)
                pc = prefix / 'lib/pkgconfig/fontconfig.pc'
                pc.parent.mkdir(parents=True)
                pc.write_text('prefix=' + str(prefix) + '\n' + line + '\n')
                result = subprocess.run(['python3', str(ROOT / 'tools/check-ohos-fontconfig.py'),
                                         '--prefix', str(prefix), '--nm', 'nm'],
                                        capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0, line)
                self.assertIn('absolute', result.stderr)

    def test_rejects_path_escaping_target_prefix(self):
        with tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR')) as directory:
            prefix = Path(directory)
            pc = prefix / 'lib/pkgconfig/fontconfig.pc'
            pc.parent.mkdir(parents=True)
            pc.write_text(f'prefix={prefix}\nLibs.private: ${{prefix}}/../../host/libfoo.a\n')
            result = subprocess.run(['python3', str(ROOT / 'tools/check-ohos-fontconfig.py'),
                                     '--prefix', str(prefix), '--nm', 'nm'],
                                    capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('absolute', result.stderr)


class FontconfigRecipe(unittest.TestCase):
    def test_recipe_rejects_host_gettext_in_generated_pc(self):
        with tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR')) as directory:
            directory = Path(directory)
            # Keep the real relative layout for the post-build check.
            recipe_dir = directory / 'do-compile/ohos'
            recipe_dir.mkdir(parents=True)
            shutil.copyfile(ROOT / 'do-compile/ohos/fontconfig.sh', recipe_dir / 'fontconfig.sh')
            shutil.copytree(ROOT / 'tools', directory / 'tools')
            helper = recipe_dir / 'meson-compatible.sh'
            helper.write_text('#!/bin/sh\nexit 0\n')
            helper.chmod(0o755)
            prefix = directory / 'product'
            pc = prefix / 'lib/pkgconfig/fontconfig.pc'
            pc.parent.mkdir(parents=True)
            pc.write_text('Libs: -lfontconfig\nLibs.private: /usr/local/lib/libintl.a\n')
            env = dict(os.environ, MR_BUILD_PREFIX=str(prefix), MR_NM='nm')
            result = subprocess.run(['bash', 'fontconfig.sh'], cwd=recipe_dir,
                                    env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0, 'contaminated fontconfig.pc was accepted')
            self.assertIn('libintl', result.stderr)

    def test_nls_is_explicitly_disabled(self):
        # Execute the real recipe; intercept only the shared build entry point.
        with tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR')) as directory:
            directory = Path(directory)
            shutil.copyfile(ROOT / 'do-compile/ohos/fontconfig.sh', directory / 'fontconfig.sh')
            helper = directory / 'meson-compatible.sh'
            helper.write_text('#!/bin/sh\nprintf "%s\\n" "$@"\n')
            helper.chmod(0o755)
            result = subprocess.run(['bash', 'fontconfig.sh'], cwd=directory,
                                    capture_output=True, text=True)
            # Only this test intercepts the builder; artifact validation is separate.
            self.assertIn('-Dnls=disabled', result.stdout.split())


if __name__ == '__main__':
    unittest.main()
