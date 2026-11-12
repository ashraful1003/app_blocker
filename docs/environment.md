# Cloud Session Environment

What `scripts/setup_cloud.sh` managed to install in this session.

## Installed

| Tool | Version | Status |
|------|---------|--------|
| Flutter | 3.47.9 (stable) | Installed at /opt/flutter |
| Dart SDK | 3.13.7 (stable) | Included with Flutter |
| Java | OpenJDK 21.0.12.1 | Pre-installed |
| Gradle | 9.3.1 (via wrapper) | Bundled with project |

## Partially installed

| Tool | Status |
|------|--------|
| Android SDK | Auto-installed by Gradle (platform 36, build-tools 36.0.0, platform-tools). Located at ANDROID_HOME. |
| Android command-line tools | Not installed separately; Gradle handles SDK components. |

## Session mode

**Full environment.** All Dart and Kotlin checks run in this session.
Gradle auto-downloads needed Android SDK components when ANDROID_HOME is set.

## What works in this session

- `dart format`, `flutter analyze`, `flutter test` — full Dart toolchain
- `./gradlew :rules-engine:test` — pure Kotlin/JVM tests (no Android SDK needed)
- `./gradlew ktlintCheck` — Kotlin style checks

## What needs CI

- `flutter build apk` — needs Android SDK
- `./gradlew :app:testDebugUnitTest` — needs Android SDK for Robolectric
- Debug APK build and upload — handled by `pr.yml` workflow

## Environment variables

Set `ANDROID_HOME` if the Android SDK is installed:
```bash
export ANDROID_HOME=/opt/android-sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

Flutter SDK is at `/opt/flutter`:
```bash
export PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"
```
