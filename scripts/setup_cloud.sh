#!/usr/bin/env bash
set -euo pipefail

echo "=== App Blocker cloud session setup ==="

DART_ONLY=false

# 1. Read pinned Flutter version from pubspec.yaml
FLUTTER_VERSION=$(grep '  flutter:' pubspec.yaml | head -1 | awk '{print $2}')
if [ -z "$FLUTTER_VERSION" ]; then
  echo "Warning: could not read Flutter version from pubspec.yaml, using 3.47.9"
  FLUTTER_VERSION="3.47.9"
fi
echo "Pinned Flutter version: $FLUTTER_VERSION"

# Install Flutter if missing or wrong version
FLUTTER_DIR="/opt/flutter"
if command -v flutter &>/dev/null; then
  CURRENT=$(flutter --version 2>/dev/null | head -1 | awk '{print $2}')
  if [ "$CURRENT" = "$FLUTTER_VERSION" ]; then
    echo "Flutter $FLUTTER_VERSION already installed."
  else
    echo "Flutter $CURRENT found but need $FLUTTER_VERSION. Reinstalling..."
    rm -rf "$FLUTTER_DIR"
  fi
fi

if ! command -v flutter &>/dev/null; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR" 2>&1 || {
    echo "Warning: exact tag $FLUTTER_VERSION not found, trying stable..."
    git clone --depth 1 --branch stable \
      https://github.com/flutter/flutter.git "$FLUTTER_DIR" 2>&1
  }
fi

export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"

# 2. Flutter pub get and precache
echo "Running flutter pub get..."
flutter pub get

echo "Running flutter precache --android..."
flutter precache --android 2>&1 || echo "Warning: precache had issues, continuing."

# 3. Java 17+
if command -v java &>/dev/null; then
  JAVA_VER=$(java -version 2>&1 | head -1 | grep -oP '"\K[^"]+' | cut -d. -f1)
  echo "Java version: $JAVA_VER"
  if [ "$JAVA_VER" -lt 17 ] 2>/dev/null; then
    echo "Warning: Java $JAVA_VER found but 17+ is needed."
  fi
else
  echo "Warning: Java not found. Kotlin checks will be skipped."
  DART_ONLY=true
fi

# 4. Android SDK
ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
export ANDROID_HOME
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

if [ ! -d "$ANDROID_HOME/cmdline-tools" ]; then
  echo "Installing Android command-line tools..."
  mkdir -p "$ANDROID_HOME"
  CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
  TMPZIP="/tmp/cmdline-tools.zip"
  curl -fsSL "$CMDLINE_TOOLS_URL" -o "$TMPZIP" 2>&1 || {
    echo "Warning: could not download Android command-line tools."
    DART_ONLY=true
  }
  if [ "$DART_ONLY" = false ]; then
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    unzip -q "$TMPZIP" -d "$ANDROID_HOME/cmdline-tools" 2>&1 || DART_ONLY=true
    if [ -d "$ANDROID_HOME/cmdline-tools/cmdline-tools" ]; then
      mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
    fi
    rm -f "$TMPZIP"
  fi
fi

if [ "$DART_ONLY" = false ] && command -v sdkmanager &>/dev/null; then
  echo "Installing Android SDK components..."
  yes | sdkmanager --licenses 2>&1 | tail -1 || true
  sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.1" 2>&1 | tail -5 || {
    echo "Warning: some Android SDK components failed to install."
    DART_ONLY=true
  }
else
  if [ "$DART_ONLY" = false ]; then
    echo "Warning: sdkmanager not found."
    DART_ONLY=true
  fi
fi

# 5. Set environment
export ANDROID_HOME
echo "ANDROID_HOME=$ANDROID_HOME"

# 6. Flutter doctor
echo ""
echo "=== Flutter doctor ==="
flutter doctor -v 2>&1 | grep -E '^\[|Doctor summary' || true

# 7. Summary
echo ""
echo "=== Setup summary ==="
echo "Flutter: $(flutter --version 2>/dev/null | head -1)"
echo "Dart: $(dart --version 2>/dev/null)"
echo "Java: $(java -version 2>&1 | head -1)"
if [ "$DART_ONLY" = true ]; then
  echo ""
  echo "*** DART-ONLY SESSION ***"
  echo "Android SDK is not fully available. Kotlin/Android checks will be skipped."
  echo "CI still runs everything."
  touch /tmp/.dart_only_session
else
  echo "Android SDK: $ANDROID_HOME"
  echo "Full environment ready."
  rm -f /tmp/.dart_only_session
fi
