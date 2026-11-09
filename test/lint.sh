#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for script in "$repo_root"/test/*.sh; do
  bash -n "$script"
done

node --check "$repo_root/test/coverage.js"
node -e "JSON.parse(require('fs').readFileSync('$repo_root/autoload/palettes.json', 'utf8'))"

for executable in \
  "$repo_root/test/run.sh" \
  "$repo_root/test/coverage.sh" \
  "$repo_root/test/lint.sh" \
  "$repo_root/test/release.sh"; do
  [[ -x "$executable" ]]
done

git -C "$repo_root" diff --check
"$repo_root/test/release.sh"
printf 'Lint checks passed.\n'
