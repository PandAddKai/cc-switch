#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local/bin}"

mkdir -p "$PREFIX"

link() {
  local name="$1"
  ln -sf "$ROOT_DIR/$name" "$PREFIX/$name"
}

link cc-switch
link cc-use
link cc-add
link cc-edit
link cc-del
link cc-list
link cc-current
link cc
link cc-env

cat <<EOF
OK: installed symlinks into $PREFIX
- cc-switch cc-use cc-add cc-edit cc-del cc-list cc-current cc cc-env

Make sure $PREFIX is in PATH.
EOF
