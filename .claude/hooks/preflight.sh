#!/usr/bin/env bash
set -euo pipefail

LOCK="/tmp/.preflight_running"
if [ -f "$LOCK" ]; then
  exit 0
fi
touch "$LOCK"
trap 'rm -f "$LOCK"' EXIT

echo "Running preflight checks..."

export PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

if command -v dart &>/dev/null; then
  echo "  Analyzing Dart..."
  dart analyze --no-fatal-infos lib/ test/ 2>&1 || {
    echo "PREFLIGHT FAILED: dart analyze has errors." >&2
    exit 1
  }
fi

CHANGED=$(git diff --name-only HEAD 2>/dev/null || true)
if echo "$CHANGED" | grep -q '\.dart$'; then
  echo "  Running Dart tests for changed files..."
  flutter test 2>&1 || {
    echo "PREFLIGHT FAILED: Dart tests failed." >&2
    exit 1
  }
fi

if echo "$CHANGED" | grep -q '\.kt$'; then
  if [ -f android/gradlew ]; then
    echo "  Running rules-engine tests..."
    (cd android && ./gradlew :rules-engine:test 2>&1) || {
      echo "PREFLIGHT FAILED: Kotlin tests failed." >&2
      exit 1
    }
  fi
fi

echo "Preflight passed."
