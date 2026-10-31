#!/usr/bin/env python3
"""Exercise custom-workflow ordering without compiling or publishing anything."""
from pathlib import Path
import os
import subprocess
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / '.github/workflows/build custom libs.yml'
ORDER = ('bluray', 'fontconfig', 'harfbuzz', 'ass', 'ffmpeg8')


def run_body():
    lines = WORKFLOW.read_text().splitlines()
    start = lines.index('    - name: One Step')
    start = lines.index('      run: |', start) + 1
    body = []
    for line in lines[start:]:
        if line and not line.startswith('        '):
            break
        body.append(line[8:] if line.startswith('        ') else line)
    script = '\n'.join(body)
    # Support the previous inline-input version so RED tests exercise its behavior.
    for key, value in {'platform': 'ohos', 'draft': 'false', 'verbose': 'true'}.items():
        script = script.replace('${{ inputs.' + key + ' }}', value)
    script = script.replace('${{ inputs.libraries }}', '$BUILD_LIBRARIES')
    return script


class CustomOHOSWorkflow(unittest.TestCase):
    def execute(self, libraries=','.join(ORDER), fail=''):
        base = Path(os.environ.get('TMPDIR', str(Path.home() / '.hermes/cache/scratch')))
        with tempfile.TemporaryDirectory(prefix='toolchain-custom-test-', dir=base) as tmp:
            root = Path(tmp)
            workflows = root / '.github/workflows'
            workflows.mkdir(parents=True)
            configs = root / 'configs/libs'
            configs.mkdir(parents=True)
            for lib in ORDER:
                (configs / f'{lib}.sh').touch()
            install = workflows / 'install-dependencies.sh'
            install.write_text(textwrap.dedent('''\
                #!/bin/bash
                set -eu
                printf 'install %s %s\n' "$1" "$2" >> "$TEST_LOG"
                if [[ "$1" == ass ]]; then
                  test -f published-fontconfig || exit 7
                  test -f published-harfbuzz || exit 7
                fi
                if [[ "$1" == ffmpeg8 ]]; then test -f published-bluray || exit 7; fi
                '''))
            build = workflows / 'onestep.sh'
            build.write_text(textwrap.dedent('''\
                #!/bin/bash
                set -eu
                printf 'build %s %s %s %s\n' "$1" "$2" "$3" "$4" >> "$TEST_LOG"
                if [[ "$1" == "$FAIL_LIB" ]]; then exit 9; fi
                touch "published-$1"
                '''))
            install.chmod(0o700)
            build.chmod(0o700)
            log = root / 'calls.log'
            env = dict(os.environ, BUILD_PLATFORM='ohos', BUILD_DRAFT='false',
                       BUILD_VERBOSE='true', BUILD_LIBRARIES=libraries,
                       TEST_LOG=str(log), FAIL_LIB=fail)
            result = subprocess.run(['bash', '-e', '-o', 'pipefail', '-c', run_body()],
                                    cwd=root, env=env, capture_output=True, text=True)
            calls = log.read_text().splitlines() if log.exists() else []
            return result, calls

    def test_sdk_and_platform_are_declared(self):
        workflow = WORKFLOW.read_text()
        self.assertIn('Setup HarmonyOS native SDK', workflow)
        self.assertIn('          - ohos', workflow)
        self.assertIn('          - macos-15-intel', workflow)

    def test_builds_in_order_after_prerequisites_are_published(self):
        result, calls = self.execute()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        expected = []
        for lib in ORDER:
            expected.extend([f'install {lib} ohos', f'build {lib} ohos false true'])
        self.assertEqual(calls, expected)

    def test_failure_stops_downstream_builds(self):
        result, calls = self.execute(fail='fontconfig')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, ['install bluray ohos', 'build bluray ohos false true',
                                 'install fontconfig ohos', 'build fontconfig ohos false true'])

    def test_invalid_library_fails_before_any_installation(self):
        result, calls = self.execute(libraries='bluray,../../oops')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])

    def test_cleanup_never_falls_back_to_git_reset(self):
        self.assertNotIn('git reset --hard', run_body())


if __name__ == '__main__':
    unittest.main()
