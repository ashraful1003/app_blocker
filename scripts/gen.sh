#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

echo "=== Code generation ==="

# Run build_runner if there are generators configured
if grep -q 'build_runner' pubspec.yaml 2>/dev/null; then
  echo "Running build_runner..."
  dart run build_runner build --delete-conflicting-outputs
else
  echo "No build_runner dependency found, skipping."
fi

# Run pigeon if the contract file exists and pigeon is a dependency
if [ -f pigeons/blocker_api.dart ] && grep -q 'pigeon' pubspec.yaml 2>/dev/null; then
  echo "Running pigeon..."
  dart run pigeon --input pigeons/blocker_api.dart
else
  echo "No pigeon dependency configured, skipping."
fi

echo "Code generation complete."
