# App Blocker — Architecture

## Overview

App Blocker is a Flutter + Kotlin Android app. Flutter (Dart) owns the UI,
settings and business rules. Kotlin owns real-time enforcement: blocking app
launches and reading browser URLs. The two sides communicate through a
type-safe Pigeon bridge.

## Layers

### 1. Presentation (Flutter)

Screens and widgets live in `lib/features/<feature>/presentation/`.
Each screen reads from a Riverpod controller and never calls platform
APIs directly.

### 2. Application (Flutter)

Controllers and use cases live in `lib/features/<feature>/application/`.
They coordinate between data sources and expose state to the presentation
layer through Riverpod providers.

### 3. Data (Flutter)

Repositories, Drift database tables and platform wrappers live in
`lib/features/<feature>/data/`. Repositories are the single source of
truth for their domain.

### 4. Policy (Pure Dart)

`lib/policy/` contains the rules that decide:
- Whether a change is stricter or weaker.
- Whether approval is needed (strict mode + weaker change).
- TOTP code validation and lockout.
- 24-hour wait logic.
- Streak counting.

This module has no Flutter or Android imports. It is tested fully in the
cloud with `flutter test`.

### 5. Bridge (Pigeon)

`pigeons/blocker_api.dart` defines the contract. Generated code lands in
`lib/platform/` (Dart side) and `android/app/src/main/kotlin/app/blocker/bridge/`
(Kotlin side). No raw MethodChannel calls are allowed.

### 6. Enforcement (Kotlin)

The Kotlin side runs independently of Flutter:
- **Accessibility service** detects app launches and reads browser URLs.
- **Foreground service** keeps enforcement alive.
- **Boot receiver** restarts enforcement after reboot.
- **Block screen** is a native Activity (Jetpack Compose) that appears
  within 1 second.
- **Rules snapshot** is an encrypted file that Kotlin reads on its own.
- **Monotonic clock** survives reboots and ignores wall-clock changes.

### 7. Rules Engine (Pure Kotlin)

`android/rules-engine/` is a pure JVM module with no Android dependencies.
It answers: "Is this app or website blocked right now?" given the rules
snapshot and the current time. Tested with JUnit on the JVM.

## Data flow

```
User changes settings
        │
        ▼
  Dart policy logic
  (stricter/weaker, approval)
        │
        ▼
  Dart saves to encrypted DB
        │
        ▼
  Dart builds rules snapshot
        │
        ▼
  Pigeon sends snapshot to Kotlin
        │
        ▼
  Kotlin stores encrypted snapshot
        │
        ▼
  Kotlin enforces from snapshot
  (no Dart needed)
```

## Decisions

See `docs/adr/` for recorded architecture decisions:
- ADR-0001: Flutter + Kotlin split
- ADR-0002: Snapshot-based enforcement
- ADR-0003: Monotonic clock
- ADR-0004: Generated code committed
- ADR-0005: Own TOTP module
- ADR-0006: Accessibility + native block screen
- ADR-0007: No network in v1
- ADR-0008: Per-browser settings file

## Testing strategy

| Layer | Tested with | Runs in |
|-------|------------|---------|
| Policy (Dart) | flutter test | Cloud + CI |
| Rules engine (Kotlin) | JUnit | Cloud + CI |
| Snapshot contract | Shared JSON test vectors | Cloud + CI |
| Repositories/controllers | flutter test + fakes | Cloud + CI |
| Screens | Widget tests | Cloud + CI |
| Kotlin services | Robolectric | CI |
| End to end | Emulator in nightly CI | CI |
| Real phones | Manual device checklist | Before milestone close |
