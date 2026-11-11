#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

echo "=== App Blocker checks ==="

# 1. Format check
echo ""
echo "--- Step 1: dart format ---"
dart format --set-exit-if-changed . || {
  echo "FAIL: dart format found unformatted files." >&2
  exit 1
}

# 2. Analyze
echo ""
echo "--- Step 2: flutter analyze ---"
flutter analyze --no-fatal-infos || {
  echo "FAIL: flutter analyze has warnings or errors." >&2
  exit 1
}

# 3. Generated-code freshness
echo ""
echo "--- Step 3: generated-code check ---"
bash scripts/gen.sh
if ! git diff --quiet; then
  echo "FAIL: generated code is stale. Run scripts/gen.sh and commit." >&2
  git diff --stat
  exit 1
fi

# 4. Dart tests with coverage
echo ""
echo "--- Step 4: flutter test ---"
flutter test --coverage || {
  echo "FAIL: Dart tests failed." >&2
  exit 1
}

# Check policy coverage if lcov is available and policy tests exist
if [ -f coverage/lcov.info ] && command -v lcov &>/dev/null; then
  POLICY_COV=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | grep -oP '[\d.]+(?=%)' || echo "0")
  echo "lib/policy/ coverage: ${POLICY_COV}%"
  if [ "$(echo "$POLICY_COV < 95" | bc -l 2>/dev/null || echo 1)" = "1" ] && [ "$POLICY_COV" != "0" ]; then
    if [ -d lib/policy ] && find lib/policy -name '*.dart' ! -name '*.g.dart' | grep -q .; then
      echo "Warning: lib/policy/ coverage is below 95%. Target: 95%+"
    fi
  fi
fi

# 5. Kotlin checks
echo ""
echo "--- Step 5: Kotlin checks ---"
if [ -f /tmp/.dart_only_session ]; then
  echo "WARNING: Dart-only session. Skipping Kotlin checks (CI will run them)."
else
  export ANDROID_HOME="${ANDROID_HOME:-/tmp/fake-android-sdk}"
  mkdir -p "$ANDROID_HOME/licenses" 2>/dev/null || true
  if [ -f android/gradlew ]; then
    echo "Running ktlintCheck and rules-engine tests..."
    (cd android && ./gradlew ktlintCheck :rules-engine:test) || {
      echo "FAIL: Kotlin checks failed." >&2
      exit 1
    }
  else
    echo "WARNING: android/gradlew not found. Skipping Kotlin checks."
  fi
fi

# 6. Robolectric / Android unit tests
echo ""
echo "--- Step 6: Android unit tests ---"
if [ -f /tmp/.dart_only_session ]; then
  echo "WARNING: Dart-only session. Skipping Android unit tests (CI will run them)."
elif [ ! -d "${ANDROID_HOME:-/nonexistent}" ]; then
  echo "WARNING: Android SDK not installed. Skipping Android unit tests (CI will run them)."
else
  if [ -f android/gradlew ]; then
    (cd android && ./gradlew :app:testDebugUnitTest) || {
      echo "FAIL: Android unit tests failed." >&2
      exit 1
    }
  fi
fi

echo ""
echo "=== All checks passed ==="
