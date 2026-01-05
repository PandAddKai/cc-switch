#!/usr/bin/env bash
set -euo pipefail

cc_switch_resolve_bin() {
  local script_dir
  script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
  if [[ -x "$script_dir/cc-switch" ]]; then
    echo "$script_dir/cc-switch"
    return 0
  fi

  if command -v cc-switch >/dev/null 2>&1; then
    echo "cc-switch"
    return 0
  fi

  cat >&2 <<'EOF'
error: cannot find `cc-switch`.

Fix:
  - Run ./install.sh from this folder; or
  - Ensure `cc-switch` is in PATH.
EOF
  return 1
}
