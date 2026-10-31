"""SDK installer unit/security tests; fixtures are not real SDK acceptance."""
import importlib.util
from pathlib import Path
import unittest
import hashlib
import json
import os
import tempfile
import zipfile
import stat
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / '.github/workflows/setup-ohos-sdk.py'


def installer():
    if not SCRIPT.is_file():
        raise AssertionError('Shared SDK installer is missing')
    spec = importlib.util.spec_from_file_location('ohos_sdk_setup', SCRIPT)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class HostTests(unittest.TestCase):
    def test_host_aliases_and_unsupported_hosts(self):
        sdk = installer()
        for arch in ('arm64', 'aarch64'):
            self.assertEqual(sdk.select_host('Darwin', arch), 'darwin-arm64')
        for arch in ('x86_64', 'amd64'):
            self.assertEqual(sdk.select_host('Darwin', arch), 'darwin-x86_64')
        for system, arch in [('Linux', 'arm64'), ('Darwin', 'i386')]:
            with self.assertRaises(ValueError):
                sdk.select_host(system, arch)


class IntegrityTests(unittest.TestCase):
    def test_checksum_and_manifest_validation(self):
        sdk = installer()
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            archive = Path(tmp) / 'native.zip'
            archive.write_bytes(b'archive fixture')
            digest = hashlib.sha256(archive.read_bytes()).hexdigest()
            sdk.verify_checksum(archive, digest)
            with self.assertRaisesRegex(ValueError, 'SHA256'):
                sdk.verify_checksum(archive, '0' * 64)
            manifest = Path(tmp) / 'manifest.json'
            data = {'version': '5.0.0.71', 'api_version': '12', 'hosts': {
                host: {'url': 'https://example.invalid/native.zip', 'sha256': digest}
                for host in ('darwin-arm64', 'darwin-x86_64')}}
            manifest.write_text(json.dumps(data))
            self.assertEqual(sdk.load_manifest(manifest), data)
            for field, bad in [('sha256', 'bad'), ('url', 'http://insecure.invalid/a')]:
                changed = json.loads(json.dumps(data))
                changed['hosts']['darwin-arm64'][field] = bad
                manifest.write_text(json.dumps(changed))
                with self.assertRaises(ValueError):
                    sdk.load_manifest(manifest)
            del data['hosts']['darwin-x86_64']
            manifest.write_text(json.dumps(data))
            with self.assertRaises(ValueError):
                sdk.load_manifest(manifest)


class ArchiveTests(unittest.TestCase):
    def test_safe_extraction_preserves_notice_permissions_and_internal_links(self):
        sdk = installer()
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            root = Path(tmp)
            archive = root / 'sdk.zip'
            with zipfile.ZipFile(archive, 'w') as z:
                z.writestr('native/NOTICE', 'license notice')
                binary = zipfile.ZipInfo('native/llvm/bin/clang-15')
                binary.external_attr = (stat.S_IFREG | 0o755) << 16
                z.writestr(binary, b'fixture, not a compiler')
                link = zipfile.ZipInfo('native/llvm/bin/clang')
                link.external_attr = (stat.S_IFLNK | 0o777) << 16
                z.writestr(link, 'clang-15')
            native = sdk.extract_archive(archive, root / 'out')
            self.assertEqual((native / 'NOTICE').read_text(), 'license notice')
            self.assertTrue((native / 'llvm/bin/clang').is_symlink())
            self.assertTrue(os.access(native / 'llvm/bin/clang', os.X_OK))

    def test_unsafe_archives_are_rejected_before_any_extraction(self):
        sdk = installer()
        cases = [('../escaped', None), ('/absolute', None),
                 ('native/../../escaped', None), ('wrapper/native/file', None),
                 ('native/link', '/tmp/escape'), ('native/link', '../../escape'),
                 ('native/dir/link', '../../../escape')]
        for name, target in cases:
            with self.subTest(name=name, target=target), tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
                root = Path(tmp)
                archive = root / 'sdk.zip'
                with zipfile.ZipFile(archive, 'w') as z:
                    z.writestr('native/NOTICE', 'notice')
                    info = zipfile.ZipInfo(name)
                    if target is not None:
                        info.external_attr = (stat.S_IFLNK | 0o777) << 16
                    z.writestr(info, target or 'unsafe')
                with self.assertRaises(ValueError):
                    sdk.extract_archive(archive, root / 'out')
                self.assertFalse((root / 'out/native/NOTICE').exists())

    def test_symlink_ancestor_and_duplicate_members_are_rejected(self):
        sdk = installer()
        for symlink in (True, False):
            with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
                root = Path(tmp)
                archive = root / 'sdk.zip'
                with zipfile.ZipFile(archive, 'w') as z:
                    info = zipfile.ZipInfo('native/link')
                    info.external_attr = ((stat.S_IFLNK if symlink else stat.S_IFREG) | 0o755) << 16
                    z.writestr(info, 'safe')
                    z.writestr('native/link/file' if symlink else 'native/./link', 'content')
                with self.assertRaises(ValueError):
                    sdk.extract_archive(archive, root / 'out')


class ValidationTests(unittest.TestCase):
    def test_metadata_and_native_clang_are_checked_before_export(self):
        sdk = installer()
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            native = Path(tmp) / 'native'
            (native / 'llvm/bin').mkdir(parents=True)
            clang = native / 'llvm/bin/clang'
            clang.write_bytes(b'unit fixture, never executed')
            clang.chmod(0o755)
            metadata = native / 'oh-uni-package.json'
            metadata.write_text(json.dumps({'version': '5.0.0.71', 'apiVersion': '12'}))
            manifest = {'version': '5.0.0.71', 'api_version': '12'}
            with mock.patch.object(sdk.subprocess, 'run') as run:
                run.return_value.stdout = 'Mach-O 64-bit executable arm64'
                sdk.validate_sdk(native, manifest, 'darwin-arm64')
                self.assertEqual(run.call_args_list[0].args[0], ['file', '-b', '-L', str(clang)])
                self.assertEqual(run.call_args_list[1].args[0], [str(clang), '--version'])
            for data in ({'version': 'wrong', 'apiVersion': '12'},
                         {'version': '5.0.0.71', 'apiVersion': '13'}):
                metadata.write_text(json.dumps(data))
                with mock.patch.object(sdk.subprocess, 'run') as run:
                    with self.assertRaisesRegex(ValueError, 'metadata'):
                        sdk.validate_sdk(native, manifest, 'darwin-arm64')
                    run.assert_not_called()
            metadata.write_text(json.dumps({'version': '5.0.0.71', 'apiVersion': '12'}))
            for output in ('ELF 64-bit executable arm64', 'Mach-O 64-bit executable x86_64'):
                with mock.patch.object(sdk.subprocess, 'run') as run:
                    run.return_value.stdout = output
                    with self.assertRaisesRegex(ValueError, 'Mach-O'):
                        sdk.validate_sdk(native, manifest, 'darwin-arm64')
                    self.assertEqual(run.call_count, 1)
            env = Path(tmp) / 'env'
            sdk.export_environment(native, env)
            self.assertEqual(env.read_text(), f'OHOS_SDK_NATIVE={native.resolve()}\n')
            with self.assertRaisesRegex(ValueError, 'newline'):
                sdk.export_environment(Path(tmp) / 'bad\nINJECT=1', env)
            self.assertEqual(env.read_text(), f'OHOS_SDK_NATIVE={native.resolve()}\n')


class InstallationTests(unittest.TestCase):
    def test_curl_download_uses_partial_and_removes_it_on_failure(self):
        sdk = installer()
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            archive = Path(tmp) / 'native.zip'
            def downloaded(command, **kwargs):
                self.assertIn('curl', command)
                self.assertIn('--fail', command)
                self.assertIn('--location', command)
                self.assertIn('--proto-redir', command)
                Path(command[command.index('--output') + 1]).write_bytes(b'download fixture')
            with mock.patch.object(sdk.subprocess, 'run', side_effect=downloaded):
                sdk.download_archive('https://example.invalid/sdk.zip', archive)
            self.assertEqual(archive.read_bytes(), b'download fixture')
            self.assertFalse(archive.with_suffix('.zip.part').exists())
            archive.unlink()
            def failed(command, **kwargs):
                downloaded(command, **kwargs)
                raise sdk.subprocess.CalledProcessError(22, command)
            with mock.patch.object(sdk.subprocess, 'run', side_effect=failed):
                with self.assertRaises(sdk.subprocess.CalledProcessError):
                    sdk.download_archive('https://example.invalid/sdk.zip', archive)
            self.assertFalse(archive.exists())
            self.assertFalse(archive.with_suffix('.zip.part').exists())

    def test_local_archive_installs_in_private_directory_and_exports_only_after_validation(self):
        sdk = installer()
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            root = Path(tmp)
            archive = root / 'sdk.zip'
            with zipfile.ZipFile(archive, 'w') as z:
                z.writestr('native/NOTICE', 'notice')
            digest = hashlib.sha256(archive.read_bytes()).hexdigest()
            manifest = root / 'manifest.json'
            manifest.write_text(json.dumps({'version': '5.0.0.71', 'api_version': '12', 'hosts': {
                host: {'url': 'https://example.invalid/native.zip', 'sha256': digest}
                for host in ('darwin-arm64', 'darwin-x86_64')}}))
            env = root / 'env'
            args = ['--manifest', str(manifest), '--archive', str(archive),
                    '--work-dir', str(root / 'work'), '--env-file', str(env)]
            with mock.patch.object(sdk, 'select_host', return_value='darwin-arm64'), \
                 mock.patch.object(sdk, 'validate_sdk') as validate:
                self.assertEqual(sdk.main(args), 0)
                native = validate.call_args.args[0]
                self.assertTrue(native.is_relative_to(root / 'work'))
                self.assertEqual((native / 'NOTICE').read_text(), 'notice')
                self.assertEqual(env.read_text(), f'OHOS_SDK_NATIVE={native}\n')
            env.unlink()
            with mock.patch.object(sdk, 'select_host', return_value='darwin-arm64'), \
                 mock.patch.object(sdk, 'validate_sdk', side_effect=ValueError('metadata mismatch')):
                with self.assertRaisesRegex(ValueError, 'metadata mismatch'):
                    sdk.main(args)
                self.assertFalse(env.exists())
            with mock.patch.object(sdk, 'select_host', return_value='darwin-arm64'), \
                 mock.patch.object(sdk, 'validate_sdk') as validate, \
                 mock.patch.dict(os.environ, {'RUNNER_TEMP': str(root / 'runner'), 'GITHUB_ENV': str(env)}):
                self.assertEqual(sdk.main(['--manifest', str(manifest), '--archive', str(archive)]), 0)
                self.assertTrue(validate.call_args.args[0].is_relative_to(root / 'runner'))


class WorkflowTests(unittest.TestCase):
    def test_all_seven_release_entries_use_shared_installer_after_checkout(self):
        workflows = ['build a lib.yml', 'build custom libs.yml', 'build all libs.yml',
                     'build all libs for ass.yml', 'build all libs for ffmpeg8.yml',
                     'build all libs for placebo.yml', 'test.yml']
        for name in workflows:
            with self.subTest(workflow=name):
                text = (ROOT / '.github/workflows' / name).read_text()
                self.assertEqual(text.count('    - name: Setup HarmonyOS native SDK'), 1)
                start = text.index('    - name: Setup HarmonyOS native SDK')
                end = text.find('    - ', start + 5)
                step = text[start:end if end >= 0 else None]
                self.assertIn("if: inputs.platform == 'ohos' || inputs.platform == 'all'", step)
                self.assertIn('run: python3 .github/workflows/setup-ohos-sdk.py', step)
                self.assertLess(text.index('uses: actions/checkout@'), start)
                self.assertNotIn('native.zip', text)
                self.assertIn('          - ohos\n', text)
                self.assertIn('          - macos-26-intel\n', text)
                self.assertIn("default: 'macos-26'", text)


if __name__ == '__main__':
    unittest.main()
