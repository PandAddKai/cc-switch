#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local/bin}"
INSTALL_ROOT="${INSTALL_ROOT:-$HOME/.local/share/cc-switch}"

rm -f \
  "$PREFIX/cc-switch" \
  "$PREFIX/cc-use" \
  "$PREFIX/cc-add" \
  "$PREFIX/cc-edit" \
  "$PREFIX/cc-del" \
  "$PREFIX/cc-list" \
  "$PREFIX/cc-current" \
  "$PREFIX/cc-status" \
  "$PREFIX/cc" \
  "$PREFIX/cc-env"

if [[ "${1:-}" == "--purge" ]]; then
  rm -rf -- "$INSTALL_ROOT"
  echo "OK: removed from $PREFIX"
  echo "OK: purged $INSTALL_ROOT"
else
  echo "OK: removed from $PREFIX"
  echo "Note: kept $INSTALL_ROOT (run: uninstall.sh --purge)"
fi
