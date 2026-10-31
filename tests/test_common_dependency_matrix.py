#!/usr/bin/env python3
"""Combined dependency lists must match supported single-platform lists."""
from functools import lru_cache
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / '.github/workflows/install-dependencies.sh'
PLATFORMS = ('ios', 'tvos', 'macos', 'android', 'ohos')
LIBRARIES = ('bluray', 'fontconfig', 'harfbuzz')


@lru_cache(maxsize=None)
def dependencies(library, platform):
    result = subprocess.run(['zsh', str(SCRIPT), library, platform, '--list'],
                            cwd=ROOT, check=True, capture_output=True, text=True)
    rows = tuple(tuple(line.split()) for line in result.stdout.splitlines() if line.strip())
    if any(len(row) != 2 or row[0] not in PLATFORMS for row in rows):
        raise AssertionError(f'Malformed dependency listing: {result.stdout}')
    if len(rows) != len(set(rows)):
        raise AssertionError(f'Duplicate dependencies: {rows}')
    return frozenset(rows)


class CommonDependencyMatrix(unittest.TestCase):
    def test_all_matches_union_of_single_platforms(self):
        for library in LIBRARIES:
            with self.subTest(library=library):
                expected = frozenset().union(*(dependencies(library, p) for p in PLATFORMS))
                self.assertSetEqual(dependencies(library, 'all'), expected)

    def test_apple_matches_only_apple_platforms(self):
        for library in LIBRARIES:
            with self.subTest(library=library):
                expected = frozenset().union(*(dependencies(library, p) for p in PLATFORMS[:3]))
                self.assertSetEqual(dependencies(library, 'apple'), expected)

    def test_preserves_single_platform_dependencies(self):
        for library in LIBRARIES:
            for platform in PLATFORMS:
                with self.subTest(library=library, platform=platform):
                    names = {'freetype'} if library == 'harfbuzz' else {'xml2'}
                    if library == 'fontconfig' and platform in ('android', 'ohos'):
                        names.add('freetype')
                    self.assertSetEqual(dependencies(library, platform),
                                        frozenset((platform, name) for name in names))


if __name__ == '__main__':
    unittest.main()
