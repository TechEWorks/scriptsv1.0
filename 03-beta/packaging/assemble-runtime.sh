#!/usr/bin/env bash
# Create the exact runtime tree destined for release/scriptsv1.0 after approval.
set -Eeuo pipefail
[[ $# == 1 && -d $1 ]] || { echo 'Usage: assemble-runtime.sh EMPTY_OUTPUT_DIRECTORY' >&2; exit 2; }
output=$(cd -- "$1" && pwd -P)
[[ -z $(find "$output" -mindepth 1 -print -quit) ]] || { echo 'Output directory must be empty.' >&2; exit 73; }
source_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../src" && pwd -P)
install -D -m 0644 -- "$source_root/VERSION" "$output/VERSION"
for relative in bootstrap/teche bin/teche lib/wd1.0-menu.sh lib/wd1.0-uninstall.sh; do
  install -D -m 0755 -- "$source_root/$relative" "$output/$relative"
done
(
  cd -- "$output"
  sha256sum VERSION bootstrap/teche bin/teche lib/wd1.0-menu.sh lib/wd1.0-uninstall.sh > SHA256SUMS.txt
  sha256sum -c SHA256SUMS.txt
)
