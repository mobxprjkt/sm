#!/usr/bin/env bash
# Build SukiSU Ultra Manager from upstream source and place APK in ./manager_apks.
# Requires: git, cargo/rust, cross, just, JDK 21, Android SDK + NDK.
set -euo pipefail

WORK_DIR="${GITHUB_WORKSPACE:-$(pwd)}"
BUILD_ROOT="${RUNNER_TEMP:-/tmp}/sukisu-manager-build"
SKSU_REPO="${SKSU_REPO:-https://github.com/SukiSU-Ultra/SukiSU-Ultra.git}"
SKSU_REF="${SKSU_REF:-main}"

command -v git >/dev/null || { echo "[ERROR] git is required"; exit 1; }
command -v cargo >/dev/null || { echo "[ERROR] Rust/Cargo is required"; exit 1; }
command -v cross >/dev/null || { echo "[ERROR] cross is required"; exit 1; }
command -v just >/dev/null || { echo "[ERROR] just is required"; exit 1; }
command -v java >/dev/null || { echo "[ERROR] JDK 21 is required"; exit 1; }

rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT" "$WORK_DIR/manager_apks"
git clone --depth=1 --branch "$SKSU_REF" "$SKSU_REPO" "$BUILD_ROOT/source"

cd "$BUILD_ROOT/source"

# Build the ARM64 ksud binary and then the Manager APK using upstream's justfile.
just build_ksud
just build_manager

APK="$(find manager/app/build/outputs/apk -type f -name '*.apk' \
  \( -path '*/debug/*' -o -path '*/release/*' \) | sort | tail -n 1)"
if [ -z "$APK" ]; then
  echo "[ERROR] SukiSU Ultra Manager APK was not produced" >&2
  find manager/app/build/outputs -maxdepth 6 -type f -print 2>/dev/null || true
  exit 1
fi

DEST="$WORK_DIR/manager_apks/$(basename "$APK")"
cp "$APK" "$DEST"
(
  cd "$WORK_DIR/manager_apks"
  sha256sum "$(basename "$DEST")" > "$(basename "$DEST").sha256"
)
echo "[OK] Built SukiSU Ultra Manager: $DEST"
