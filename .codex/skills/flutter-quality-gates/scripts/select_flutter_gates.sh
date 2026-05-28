#!/usr/bin/env bash
set -euo pipefail

# Prints suggested Flutter quality gates from a list of changed files.
# Usage:
#   select_flutter_gates.sh path1 path2 ...
#   git diff --name-only | xargs .codex/skills/flutter-quality-gates/scripts/select_flutter_gates.sh

if [[ "$#" -eq 0 ]]; then
  echo "No paths supplied. Provide changed file paths as arguments."
  exit 1
fi

needs_l10n=0
needs_platform=0
needs_full_test=0
needs_target_test=0

for path in "$@"; do
  case "$path" in
    lib/l10n/*.arb)
      needs_l10n=1
      needs_target_test=1
      ;;
    lib/core/*|lib/core/**|lib/repositories/*|lib/repositories/**|pubspec.yaml|pubspec.lock)
      needs_full_test=1
      ;;
    lib/*|lib/**|test/*|test/**)
      needs_target_test=1
      ;;
    android/*|android/**|ios/*|ios/**|web/*|web/**|macos/*|macos/**|windows/*|windows/**|linux/*|linux/**)
      needs_platform=1
      ;;
  esac
done

echo "dart format --set-exit-if-changed ."
echo "flutter analyze"

if [[ "$needs_l10n" -eq 1 ]]; then
  echo "flutter gen-l10n"
fi

if [[ "$needs_full_test" -eq 1 ]]; then
  echo "flutter test"
elif [[ "$needs_target_test" -eq 1 ]]; then
  echo "flutter test <targeted_paths>"
fi

if [[ "$needs_platform" -eq 1 ]]; then
  echo "flutter build <impacted_platform_target>"
fi
