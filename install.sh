#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local/bin}"
INSTALL_ROOT="${INSTALL_ROOT:-$HOME/.local/share/cc-switch}"

mkdir -p "$PREFIX"
mkdir -p "$INSTALL_ROOT"

install_file() {
  local name="$1"
  install -m 0755 "$ROOT_DIR/$name" "$INSTALL_ROOT/$name"
}

install_doc() {
  local name="$1"
  install -m 0644 "$ROOT_DIR/$name" "$INSTALL_ROOT/$name"
}

link_bin() {
  local name="$1"
  ln -sf "$INSTALL_ROOT/$name" "$PREFIX/$name"
}

install_doc LICENSE
install_doc CHANGELOG.md
install_doc SECURITY.md
install_doc README.md
install_doc VERSION

install_file cc-switch
install_file cc-env
install_file cc-use
install_file cc-add
install_file cc-edit
install_file cc-del
install_file cc-list
install_file cc-current
install_file cc-status
install_file cc-lib.sh
install_file uninstall.sh

link_bin cc-switch
link_bin cc-env
link_bin cc-use
link_bin cc-add
link_bin cc-edit
link_bin cc-del
link_bin cc-list
link_bin cc-current
link_bin cc-status

  # Remove legacy `cc` alias from older installs to avoid shadowing system `cc`.
  if [[ -L "$PREFIX/cc" && "$(readlink "$PREFIX/cc")" == "$INSTALL_ROOT/cc" ]]; then
    rm -f -- "$PREFIX/cc"
  fi
  # Remove legacy wrapper file from older installs.
  rm -f -- "$INSTALL_ROOT/cc" 2>/dev/null || true

  # Remove legacy `claude` wrapper from older installs.
  if [[ -L "$PREFIX/claude" && "$(readlink "$PREFIX/claude")" == "$INSTALL_ROOT/claude" ]]; then
    rm -f -- "$PREFIX/claude"
  fi
  rm -f -- "$INSTALL_ROOT/claude" 2>/dev/null || true

cat <<EOF
OK: installed to $INSTALL_ROOT
OK: installed symlinks into $PREFIX
- cc-switch cc-env cc-use cc-add cc-edit cc-del cc-list cc-current cc-status
Note: this installer never replaces the system \`claude\` or \`cc\` commands.

Make sure $PREFIX is in PATH.
EOF
