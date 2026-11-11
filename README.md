# App Blocker

An Android app (Flutter + Kotlin) that blocks apps and websites on schedules and daily limits.

## Quick start

```bash
# Install dependencies and tools
bash scripts/setup_cloud.sh

# Run all checks
bash scripts/check.sh

# Run code generation
bash scripts/gen.sh

# Run Dart tests
flutter test

# Run Kotlin tests (requires Android SDK)
cd android && ./gradlew :rules-engine:test
```

## Project structure

- `lib/policy/` — pure Dart rules logic (stricter/weaker, TOTP, 24-hour wait, streak)
- `android/rules-engine/` — pure Kotlin blocking logic (schedules, limits, website matching)
- `lib/features/` — Flutter screens and controllers, one folder per feature
- `pigeons/blocker_api.dart` — the Dart ↔ Kotlin bridge contract
- `docs/` — architecture, decisions, task cards, testing checklists

See [CLAUDE.md](CLAUDE.md) for development rules and [docs/architecture.md](docs/architecture.md) for the full architecture.
