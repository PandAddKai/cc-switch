#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(cat "$ROOT_DIR/VERSION")"
DIST_DIR="$ROOT_DIR/dist"
OUT="$DIST_DIR/cc-switch-$VERSION.tar.gz"

mkdir -p "$DIST_DIR"

tar -czf "$OUT" \
  -C "$ROOT_DIR" \
  cc-switch \
  cc \
  cc-env \
  cc-use \
  cc-add \
  cc-edit \
  cc-del \
  cc-list \
  cc-current \
  cc-lib.sh \
  install.sh \
  uninstall.sh \
  README.md \
  LICENSE \
  CHANGELOG.md \
  SECURITY.md \
  VERSION \
  release.sh \
  .gitignore

echo "OK: wrote $OUT"
