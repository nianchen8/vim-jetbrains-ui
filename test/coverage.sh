#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
coverage_dir="$(mktemp -d /tmp/vim-jb-coverage.XXXXXX)"

cleanup() {
  find "$coverage_dir" -depth -delete
}
trap cleanup EXIT

for test_file in "$repo_root"/test/unit/*.vim "$repo_root"/test/integration/*.vim; do
  [[ -f "$test_file" ]] || continue
  test_name="$(basename "$test_file" .vim)"
  profile_file="$coverage_dir/$test_name.log"
  vim -Nu NONE -i NONE -n -es \
    --cmd "profile start $profile_file" \
    --cmd 'profile func *' \
    --cmd 'profile file *' \
    -S "$test_file"
done

node "$repo_root/test/coverage.js" "$repo_root" "$coverage_dir"
