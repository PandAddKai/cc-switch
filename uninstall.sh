#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local/bin}"

rm -f \
  "$PREFIX/cc-switch" \
  "$PREFIX/cc-use" \
  "$PREFIX/cc-add" \
  "$PREFIX/cc-edit" \
  "$PREFIX/cc-del" \
  "$PREFIX/cc-list" \
  "$PREFIX/cc-current" \
  "$PREFIX/cc" \
  "$PREFIX/cc-env"

echo "OK: removed from $PREFIX"
