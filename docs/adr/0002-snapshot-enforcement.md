# ADR 0002: Kotlin alone decides "blocked right now" from a rules snapshot

## Status
Accepted

## Context
Blocking must work even when the Flutter app is closed or not running. Kotlin
needs all the information it needs to decide whether an app or website is blocked.

## Decision
Dart owns all settings and approval rules. After every change, Dart builds a
complete rules snapshot and pushes it to Kotlin through Pigeon. Kotlin stores
an encrypted copy and enforces from it independently. Dart asks Kotlin for
live status when the UI needs it.

## Consequences
- Kotlin never needs to call Dart to make a blocking decision.
- The snapshot format is a shared contract tested with JSON test vectors.
- If the snapshot format changes, both sides must be updated together.
- A snapshot push failure means Kotlin keeps enforcing the previous rules.
