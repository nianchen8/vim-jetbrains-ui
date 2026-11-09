#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for test_file in "$repo_root"/test/unit/*.vim "$repo_root"/test/integration/*.vim; do
  [[ -f "$test_file" ]] || continue
  printf 'RUN %s\n' "${test_file#"$repo_root"/}"
  vim -Nu NONE -i NONE -n -es -V1 -S "$test_file"
done

printf 'All tests passed.\n'
