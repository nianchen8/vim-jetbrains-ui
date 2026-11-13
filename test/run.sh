#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C.UTF-8

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for test_file in "$repo_root"/test/unit/*.vim "$repo_root"/test/integration/*.vim; do
  [[ -f "$test_file" ]] || continue
  printf 'RUN %s\n' "${test_file#"$repo_root"/}"
  vim -Nu NONE -i NONE -n -X -es -V1 -S "$test_file"
done

printf 'RUN Python converter tests\n'
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover \
  -s "$repo_root/test" \
  -p 'test_*.py'

printf 'All tests passed.\n'
