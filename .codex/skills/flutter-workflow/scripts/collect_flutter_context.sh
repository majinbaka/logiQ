#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"

if [[ ! -f "$TARGET_DIR/pubspec.yaml" ]]; then
  echo "No pubspec.yaml found at: $TARGET_DIR"
  exit 1
fi

echo "== Flutter Context =="
echo "Project: $TARGET_DIR"

echo
echo "-- pubspec header --"
sed -n '1,40p' "$TARGET_DIR/pubspec.yaml"

echo
echo "-- lib top-level folders --"
if [[ -d "$TARGET_DIR/lib" ]]; then
  find "$TARGET_DIR/lib" -mindepth 1 -maxdepth 1 -type d | sort
else
  echo "lib/ directory not found"
fi

echo
echo "-- test top-level folders --"
if [[ -d "$TARGET_DIR/test" ]]; then
  find "$TARGET_DIR/test" -mindepth 1 -maxdepth 1 -type d | sort
else
  echo "test/ directory not found"
fi
