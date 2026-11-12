#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ]; then
  exit 0
fi

case "$FILE" in
  *.dart)
    if command -v dart &>/dev/null; then
      dart format "$FILE" 2>/dev/null || true
    fi
    ;;
  *.kt|*.kts)
    if command -v ktlint &>/dev/null; then
      ktlint -F "$FILE" 2>/dev/null || true
    fi
    ;;
esac
