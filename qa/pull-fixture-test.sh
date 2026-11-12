#!/usr/bin/env bash
# Exercises the public-folder pull path against a local Git fixture under /tmp.
# No ServOS system files, disks or installed WorkDesk are changed.
set -Eeuo pipefail
[[ $(id -u) == 0 && $# == 1 && -f $1/SHA256SUMS.txt ]] || {
  echo 'Usage: root pull-fixture-test.sh /path/to/extracted/runtime-package' >&2
  exit 2
}
for tool in git python3 sha256sum; do command -v "$tool" >/dev/null || exit 69; done
source_root=$(realpath "$1")
test_root=$(mktemp -d /tmp/teche-pull-fixture.XXXXXXXX)
mkdir -p "$test_root/fixture/scriptsv1.0" \
  "$test_root/logs/operations" "$test_root/logs/audit" \
  "$test_root/teche.scripts"
cp -a "$source_root/." "$test_root/fixture/scriptsv1.0/"
chmod 0755 "$test_root/fixture/scriptsv1.0/bin/teche" \
  "$test_root/fixture/scriptsv1.0/bootstrap/teche" \
  "$test_root/fixture/scriptsv1.0/lib/"*.sh
(cd "$test_root/fixture/scriptsv1.0" && sha256sum -c SHA256SUMS.txt)
# Rewrite only the fixture dispatcher path, then rehash its fixture manifest.
python3 - "$test_root/fixture/scriptsv1.0" "$test_root" <<'PY'
from hashlib import sha256
from pathlib import Path
import sys
package, root = Path(sys.argv[1]), sys.argv[2]
dispatcher = package / 'bin/teche'
code = dispatcher.read_text()
old = 'scripts_base=/teche.scripts/v1.0'
assert code.count(old) == 1, 'dispatcher path contract changed'
dispatcher.write_text(code.replace(old, f'scripts_base={root}/teche.scripts/v1.0'))
manifest = package / 'SHA256SUMS.txt'
lines = manifest.read_text().splitlines()
matches = [i for i, line in enumerate(lines) if line.endswith('  bin/teche')]
assert len(matches) == 1, 'dispatcher manifest entry missing'
lines[matches[0]] = f"{sha256(dispatcher.read_bytes()).hexdigest()}  bin/teche"
manifest.write_text('\n'.join(lines) + '\n')
PY
(cd "$test_root/fixture/scriptsv1.0" && sha256sum -c SHA256SUMS.txt)
git -C "$test_root/fixture" init -q -b main
git -C "$test_root/fixture" add scriptsv1.0
git -C "$test_root/fixture" -c user.name='TechE QA' \
  -c user.email='qa@localhost' commit -qm fixture

python3 - "$source_root/bootstrap/teche" "$test_root/sim-teche" "$test_root" <<'PY'
from pathlib import Path
import sys
source, output, root = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
code = source.read_text()
edits = [
    ('repo=https://github.com/TechEWorks/release.git', f'repo=file://{root}/fixture'),
    ('base=/teche.scripts/v1.0', f'base={root}/teche.scripts/v1.0'),
    ('root=/techev1.0/servosv1.0/logs', f'root={root}/logs'),
    ('/var/tmp/teche-scriptsv1.0.XXXXXXXX', f'{root}/stage.XXXXXXXX'),
]
for old, new in edits:
    if old not in code:
        raise SystemExit(f'Fixture patch target missing: {old}')
    code = code.replace(old, new)
for unsafe in ('base=/teche.scripts/v1.0',
               '/techev1.0/servosv1.0/logs',
               'https://github.com/TechEWorks/release.git'):
    if unsafe in code:
        raise SystemExit(f'Unpatched system path: {unsafe}')
output.write_text(code)
output.chmod(0o755)
PY

command_path=$test_root/sim-teche
"$command_path" --help > "$test_root/help-before.txt"
"$command_path" -help > "$test_root/help-alias-before.txt"
"$command_path" ver > "$test_root/version-before.txt"
grep -q 'scripts not yet installed' "$test_root/help-before.txt"
grep -q 'not installed' "$test_root/version-before.txt"

"$command_path" get scriptsv1.0 > "$test_root/get.log"
current=$test_root/teche.scripts/v1.0/current
[[ -x $current/bin/teche &&
   -f $test_root/teche.scripts/v1.0/source-commit ]]
first_target=$(readlink "$current")
"$command_path" --help > "$test_root/help-after.txt"
"$command_path" -help > "$test_root/help-alias-after.txt"
"$command_path" --version > "$test_root/version-after.txt"
"$command_path" build > "$test_root/build-routes.txt"
grep -q 'scripts 1.0.8-qa' "$test_root/help-after.txt"
grep -q 'txt-network' "$test_root/build-routes.txt"
grep -q 'gui-offline' "$test_root/build-routes.txt"
grep -q 'teche scripts version: 1.0.8-qa' "$test_root/version-after.txt"
# A non-root status call must not claim the private root cache is absent.
runuser -u nobody -- "$current/bin/teche" status wd1.0 > "$test_root/nonroot-status.txt"
grep -q 'package cache is private; run sudo teche status wd1.0' "$test_root/nonroot-status.txt"
! grep -q 'run sudo teche get wd1.0' "$test_root/nonroot-status.txt"
for args in 'update scriptsv1.0' 'get scripts' 'update scripts'; do
  read -r action target <<< "$args"
  "$command_path" "$action" "$target" >> "$test_root/aliases.log"
  [[ $(readlink "$current") == "$first_target" ]]
done

set +e
"$current/lib/wd1.0-menu.sh" > "$test_root/menu-no-pack.log" 2>&1
menu_status=$?
"$current/lib/wd1.0-uninstall.sh" > "$test_root/uninstall-refusal.log" 2>&1
uninstall_status=$?
set -e
[[ $menu_status == 2 && $uninstall_status == 78 ]]
bash -n "$current/lib/wd1.0-menu.sh"
bash -n "$current/lib/wd1.0-uninstall.sh"

printf x >> "$test_root/fixture/scriptsv1.0/bin/teche"
git -C "$test_root/fixture" add scriptsv1.0/bin/teche
git -C "$test_root/fixture" -c user.name='TechE QA' \
  -c user.email='qa@localhost' commit -qm tamper
if "$command_path" update scriptsv1.0 > "$test_root/tamper.log" 2>&1; then
  echo 'Tampered update was incorrectly accepted' >&2
  exit 65
fi
[[ $(readlink "$current") == "$first_target" ]]

printf 'fixture_pull=pass aliases=pass help=pass version=pass helpers=pass tamper_rejected=pass\n'
printf 'evidence_dir=%s\n' "$test_root"
printf 'fixture_source_commit=%s\n' "$(cat "$test_root/teche.scripts/v1.0/source-commit")"
