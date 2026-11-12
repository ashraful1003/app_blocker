# ADR 0009 — Gson for test vector parsing

## Status
Accepted

## Context
Shared test vectors in `test_vectors/` are JSON files consumed by both Dart
and Kotlin test suites. The Kotlin rules-engine module needs a JSON parser
to load them. The module is pure JVM (no Android), so Android's built-in
`org.json` is unavailable.

## Decision
Add `com.google.code.gson:gson:2.11.0` as a **testImplementation** dependency
in `android/rules-engine/build.gradle.kts`. It is test-scoped only and has
no impact on the production APK.

## Alternatives considered
- **kotlinx.serialization**: heavier setup (compiler plugin + runtime lib)
  for a test-only need.
- **Manual string parsing**: fragile and hard to maintain.
- **org.json**: available on Android but not in a pure JVM module without
  adding the standalone `org.json:json` artifact, which is less ergonomic
  than Gson.

## Consequences
- Gson is available only in rules-engine tests; production code stays
  dependency-free.
- If a future task needs JSON parsing in production Kotlin code, a separate
  ADR should evaluate the choice.
