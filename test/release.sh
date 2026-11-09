#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(cat "$repo_root/VERSION")"

grep -Fq "Version $version" "$repo_root/README.md"
grep -Fq "## [$version]" "$repo_root/CHANGELOG.md"

if [[ "${1:-}" == "--require-tag" ]]; then
  if [[ "$(git -C "$repo_root" describe --tags --exact-match 2>/dev/null || true)" != "v$version" ]]; then
    printf 'VERSION %s does not match the checked-out release tag.\n' "$version" >&2
    exit 1
  fi
fi

printf 'Release metadata consistent for v%s.\n' "$version"
