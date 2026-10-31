#!/usr/bin/env python3
"""Dependency listing must cover OHOS in the combined FFmpeg 8 build."""
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / '.github/workflows/install-dependencies.sh'


def dependencies(platform):
    result = subprocess.run(['zsh', str(SCRIPT), 'ffmpeg8', platform, '--list'],
                            cwd=ROOT, check=True, capture_output=True, text=True)
    return {tuple(line.split()) for line in result.stdout.splitlines() if line.strip()}


class FFmpeg8Dependencies(unittest.TestCase):
    def test_all_includes_complete_ohos_dependencies(self):
        ohos = dependencies('ohos')
        combined = {item for item in dependencies('all') if item[0] == 'ohos'}
        self.assertIn(('ohos', 'openssl3'), ohos)
        self.assertSetEqual(combined, ohos)


if __name__ == '__main__':
    unittest.main()
