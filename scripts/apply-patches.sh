#!/usr/bin/env bash
# Apply only the requested setlocalversion-suppress-plus patch.
# env: SOURCE_TYPE, KERNEL_SRC, WORK_DIR
set -euo pipefail

: "${KERNEL_SRC:?KERNEL_SRC is required}"
: "${SOURCE_TYPE:?SOURCE_TYPE is required}"
: "${WORK_DIR:=${GITHUB_WORKSPACE:-$(pwd)}}"

case "$SOURCE_TYPE" in
  gki)
    PATCH="$WORK_DIR/patches/common/setlocalversion-suppress-plus.patch"
    ;;
  gki-legacy)
    PATCH="$WORK_DIR/patches/gki-legacy/setlocalversion-suppress-plus.patch"
    ;;
  *)
    echo "[ERROR] Unsupported SOURCE_TYPE: $SOURCE_TYPE" >&2
    exit 1
    ;;
esac

[ -f "$PATCH" ] || { echo "[ERROR] Required patch not found: $PATCH" >&2; exit 1; }

source "$WORK_DIR/scripts/apply_patch.sh"
cd "$KERNEL_SRC"
apply_patch "$PATCH" "setlocalversion-suppress-plus" 1
echo "[OK] Only setlocalversion-suppress-plus.patch was processed"
