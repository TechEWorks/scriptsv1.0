#!/usr/bin/env bash
set -euo pipefail
cat >&2 <<'EOF'
wd1.0 uninstall is not yet release-qualified.
The current installer changes Debian packages, GNOME resources, boot/GDM
configuration and system defaults without a complete reversible receipt.
No packages, accounts, user files or ServOS configuration were removed.
Restore the pre-WorkDesk ServOS snapshot to fully revert this alpha install.
EOF
exit 78

