# ADR 0001: Flutter for screens and business rules; Kotlin for enforcement

## Status
Accepted

## Context
The app needs a rich UI that can later be ported to iOS, but also needs deep
Android integration for accessibility, device admin and background enforcement.

## Decision
Flutter handles all screens, settings and business rules (the policy layer).
Kotlin handles real-time enforcement: the accessibility service, foreground
service, boot receiver, block screen and the rules engine.

## Consequences
- The UI is cross-platform-ready from day one.
- Enforcement code is native, so it starts fast and runs without Flutter.
- The two sides must communicate through a well-defined bridge (Pigeon).
- Developers need to know both Dart and Kotlin.
