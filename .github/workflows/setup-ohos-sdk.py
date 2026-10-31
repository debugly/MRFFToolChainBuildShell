#!/usr/bin/env python3
"""Install a pinned, host-native OHOS SDK using only the Python stdlib."""
import platform
import hashlib
import json
import re
import os
from pathlib import Path, PurePosixPath
import posixpath
import shutil
import stat
import zipfile
import subprocess
import argparse
import tempfile
import sys
from urllib.parse import urlsplit


def validate_sdk(native, manifest, host):
    native = Path(native)
    with (native / 'oh-uni-package.json').open(encoding='utf-8') as stream:
        metadata = json.load(stream)
    if (metadata.get('version') != manifest['version']
            or str(metadata.get('apiVersion')) != manifest['api_version']):
        raise ValueError(f'SDK metadata mismatch: expected version {manifest["version"]}, '
                         f'API {manifest["api_version"]}; got {metadata!r}')
    clang = native / 'llvm/bin/clang'
    if not clang.is_file() or not os.access(clang, os.X_OK):
        raise ValueError(f'SDK clang is missing or not executable: {clang}')
    description = subprocess.run(['file', '-b', '-L', str(clang)], check=True,
                                 capture_output=True, text=True).stdout
    print(description.strip(), flush=True)
    arch = host.removeprefix('darwin-')
    if 'Mach-O' not in description or not re.search(r'\b' + re.escape(arch) + r'\b', description):
        raise ValueError(f'Expected Mach-O clang for {arch}, got: {description.strip()}')
    subprocess.run([str(clang), '--version'], check=True)


def export_environment(native, env_file):
    value = str(Path(native).resolve())
    if '\n' in value or '\r' in value:
        raise ValueError('SDK path must not contain a newline')
    with open(env_file, 'a', encoding='utf-8') as stream:
        stream.write(f'OHOS_SDK_NATIVE={value}\n')


def verify_checksum(archive, expected):
    digest = hashlib.sha256()
    with open(archive, 'rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    if digest.hexdigest() != expected:
        raise ValueError(f'SHA256 mismatch for {archive}')


def load_manifest(path):
    with open(path, encoding='utf-8') as stream:
        data = json.load(stream)
    for key in ('version', 'api_version'):
        if not isinstance(data.get(key), str) or not data[key]:
            raise ValueError(f'Manifest requires a nonempty {key} string')
    hosts = data.get('hosts', {})
    for host in ('darwin-arm64', 'darwin-x86_64'):
        entry = hosts.get(host, {})
        url = entry.get('url', '')
        if not isinstance(url, str) or urlsplit(url).scheme != 'https' or not urlsplit(url).netloc:
            raise ValueError(f'Manifest requires HTTPS URL for {host}')
        if not isinstance(entry.get('sha256'), str) or not re.fullmatch(r'[0-9a-f]{64}', entry['sha256']):
            raise ValueError(f'Manifest requires SHA256 for {host}')
    return data


def extract_archive(archive, destination):
    """Validate the complete ZIP before extracting into a new private directory.

    ZIP symlinks are restored, but may not be ancestors of other members. This
    prevents both direct traversal and chained symlink writes during extraction.
    """
    destination = Path(destination)
    with zipfile.ZipFile(archive) as source:
        members = {}
        links = {}
        for info in source.infolist():
            name = info.orig_filename
            path = PurePosixPath(name)
            if ('\x00' in name or '\\' in name or path.is_absolute()
                    or '..' in path.parts or not path.parts or path.parts[0] != 'native'):
                raise ValueError(f'Unsafe archive path: {name!r}')
            canonical = str(path)
            if canonical in members:
                raise ValueError(f'Duplicate archive path: {name!r}')
            mode = info.external_attr >> 16
            kind = stat.S_IFMT(mode)
            if kind not in (0, stat.S_IFREG, stat.S_IFDIR, stat.S_IFLNK):
                raise ValueError(f'Unsupported archive member: {name!r}')
            if stat.S_ISLNK(mode):
                target = source.read(info).decode('utf-8')
                normalized = posixpath.normpath(posixpath.join(str(path.parent), target))
                if (not target or target.startswith('/') or '\\' in target or '\x00' in target
                        or not normalized.startswith('native/')):
                    raise ValueError(f'Unsafe archive symlink: {name!r} -> {target!r}')
                links[canonical] = target
            members[canonical] = info
        if not members:
            raise ValueError('Archive must contain native/ at the top level')
        for name in members:
            for parent in PurePosixPath(name).parents:
                if str(parent) in members and not members[str(parent)].is_dir():
                    raise ValueError(f'Archive member has non-directory ancestor: {name!r}')
        # Do not merge with an existing tree (including pre-existing symlinks).
        destination.mkdir(parents=True, exist_ok=False)
        for name, info in members.items():
            target = destination / name
            target.parent.mkdir(parents=True, exist_ok=True)
            if info.is_dir():
                target.mkdir(exist_ok=True)
            elif name not in links:
                with source.open(info) as src, target.open('xb') as dst:
                    shutil.copyfileobj(src, dst)
                target.chmod((info.external_attr >> 16 & 0o777) or 0o644)
        for name, target in links.items():
            os.symlink(target, destination / name)
        native = destination / 'native'
        # Resolve full link chains, not just lexical targets.
        for name in links:
            try:
                resolved = (destination / name).resolve()
            except RuntimeError as error:
                raise ValueError(f'Archive symlink loop: {name}') from error
            if not resolved.is_relative_to(native.resolve()):
                raise ValueError(f'Escaping archive symlink: {name}')
        return native


def select_host(system=None, machine=None):
    system = platform.system() if system is None else system
    machine = platform.machine() if machine is None else machine
    aliases = {'arm64': 'arm64', 'aarch64': 'arm64',
               'x86_64': 'x86_64', 'amd64': 'x86_64'}
    if system != 'Darwin' or machine.lower() not in aliases:
        raise ValueError(f'Unsupported SDK host: {system}/{machine}')
    return 'darwin-' + aliases[machine.lower()]


def download_archive(url, archive):
    archive = Path(archive)
    partial = archive.with_suffix(archive.suffix + '.part')
    try:
        subprocess.run(['curl', '--fail', '--location', '--retry', '3',
                        '--retry-delay', '5', '--connect-timeout', '30',
                        '--proto', '=https', '--proto-redir', '=https',
                        '--output', str(partial), url], check=True)
        partial.replace(archive)
    finally:
        partial.unlink(missing_ok=True)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path,
                        default=Path(__file__).resolve().parents[2] / 'configs/ohos-sdk.json')
    parser.add_argument('--work-dir', type=Path, help='Parent of a new private SDK directory')
    parser.add_argument('--archive', type=Path, help='Use a local ZIP (SHA256 is still required)')
    parser.add_argument('--env-file', type=Path, help='GITHUB_ENV output file')
    args = parser.parse_args(argv)
    host = select_host()
    manifest = load_manifest(args.manifest)
    work_dir = args.work_dir
    if work_dir is None:
        runner_temp = os.environ.get('RUNNER_TEMP')
        if not runner_temp:
            parser.error('RUNNER_TEMP or --work-dir is required')
        work_dir = Path(runner_temp)
    env_file = args.env_file or os.environ.get('GITHUB_ENV')
    if not env_file:
        parser.error('GITHUB_ENV or --env-file is required')
    if '\n' in str(work_dir.resolve()) or '\r' in str(work_dir.resolve()):
        raise ValueError('SDK path must not contain a newline')
    work_dir.mkdir(parents=True, exist_ok=True)
    # Keep the SDK alive for later workflow steps; never reuse a prior tree.
    work = Path(tempfile.mkdtemp(prefix='ohos-sdk-', dir=work_dir)).resolve()
    print(f'Preparing OHOS SDK {manifest["version"]}, API {manifest["api_version"]} '
          f'for {host} in {work}', flush=True)
    archive = args.archive
    if archive is None:
        archive = work / 'native.zip'
        download_archive(manifest['hosts'][host]['url'], archive)
    verify_checksum(archive, manifest['hosts'][host]['sha256'])
    print('SHA256 verified; extracting native SDK', flush=True)
    native = extract_archive(archive, work / 'sdk')
    validate_sdk(native, manifest, host)
    export_environment(native, env_file)
    print(f'OHOS_SDK_NATIVE={native}', flush=True)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.CalledProcessError, zipfile.BadZipFile) as error:
        print(f'OHOS SDK setup failed: {error}', file=sys.stderr)
        sys.exit(1)
