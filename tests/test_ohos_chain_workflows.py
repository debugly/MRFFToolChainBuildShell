#!/usr/bin/env python3
"""The dedicated ass/ffmpeg8 chain workflows must cover the HarmonyOS set."""
from pathlib import Path
import os
import re
import subprocess
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = ROOT / '.github/workflows'
ASS = WORKFLOWS / 'build all libs for ass.yml'
FFMPEG8 = WORKFLOWS / 'build all libs for ffmpeg8.yml'


def one_step_body(workflow):
    lines = workflow.read_text().splitlines()
    start = lines.index('    - name: One Step')
    start = lines.index('      run: |', start) + 1
    body = []
    for line in lines[start:]:
        if line and not line.startswith('        '):
            break
        body.append(line[8:] if line.startswith('        ') else line)
    script = '\n'.join(body)
    return re.sub(r'\$\{\{\s*inputs\.(\w+)\s*\}\}', r'${INPUT_\1}', script)


def run_chain(workflow, platform, first):
    body = one_step_body(workflow)
    base = Path(os.environ.get('TMPDIR', str(Path.home() / '.hermes/cache/scratch')))
    with tempfile.TemporaryDirectory(prefix='chain-', dir=base) as tmp:
        root = Path(tmp)
        sub = root / '.github/workflows'
        sub.mkdir(parents=True)
        (sub / 'install-dependencies.sh').write_text(textwrap.dedent(f'''\
            #!/bin/bash
            set -eu
            printf 'install %s %s\\n' "$1" "$2" >> "$TEST_LOG"
            '''))
        (sub / 'onestep.sh').write_text(textwrap.dedent('''\
            #!/bin/bash
            set -eu
            printf 'build %s %s %s %s\\n' "$1" "$2" "$3" "$4" >> "$TEST_LOG"
            '''))
        (sub / 'install-dependencies.sh').chmod(0o700)
        (sub / 'onestep.sh').chmod(0o700)
        log = root / 'calls.log'
        env = dict(os.environ, TEST_LOG=str(log), INPUT_platform=platform,
                   INPUT_first_library=first, INPUT_draft='false', INPUT_verbose='false')
        result = subprocess.run(['bash', '-e', '-o', 'pipefail', '-c', body],
                                cwd=root, env=env, capture_output=True, text=True)
        calls = log.read_text().splitlines() if log.exists() else []
    return result, calls


def built(calls):
    return [line.split()[1] for line in calls if line.startswith('build ')]


class AssChain(unittest.TestCase):
    def test_ohos_builds_fontconfig_instead_of_skipping_it(self):
        result, calls = run_chain(ASS, 'ohos', 'xml2')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(built(calls),
                         ['xml2', 'unibreak', 'fribidi', 'freetype', 'fontconfig', 'harfbuzz', 'ass'])

    def test_apple_still_skips_fontconfig(self):
        result, calls = run_chain(ASS, 'apple', 'xml2')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn('fontconfig', built(calls))
        self.assertIn('ass', built(calls))


class FFmpeg8Chain(unittest.TestCase):
    def test_ohos_builds_only_supported_dependencies(self):
        result, calls = run_chain(FFMPEG8, 'ohos', 'openssl3')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(built(calls),
                         ['openssl3', 'opus', 'bluray', 'dav1d', 'uavs3d', 'smb2', 'soundtouch', 'ffmpeg8'])
        for skipped in ('dvdread', 'dvdnav', 'webp'):
            self.assertNotIn(skipped, built(calls))

    def test_apple_keeps_webp_and_dvd_libraries(self):
        result, calls = run_chain(FFMPEG8, 'apple', 'openssl3')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('webp', built(calls))
        self.assertIn('dvdnav', built(calls))
        self.assertNotIn('soundtouch', built(calls))


class Cleanup(unittest.TestCase):
    def test_no_destructive_git_fallback(self):
        for workflow in (ASS, FFMPEG8):
            with self.subTest(workflow=workflow.name):
                self.assertNotIn('git reset --hard', workflow.read_text())


if __name__ == '__main__':
    unittest.main()
