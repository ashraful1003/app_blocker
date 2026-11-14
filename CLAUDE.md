# App Blocker — rules for Claude

App Blocker is an Android app (Flutter + Kotlin) that blocks apps and websites on
schedules and daily limits. A trusted partner's code, or a 24-hour wait, is needed to
weaken any rule while strict mode is on.

## Read first
- Product: docs/product/SRS.md, docs/product/FRD.md (feature IDs FR-01..FR-13)
- Architecture: docs/architecture.md   Decisions: docs/adr/
- Your current task: the card in docs/tasks/ named in the prompt

## How you work
1. Work on ONE task card at a time, on its own branch: task/<card-id>-<short-name>.
2. Read the card, the FR sections it cites and the relevant ADRs before coding.
3. Write or update tests FIRST for any logic change. Then make them pass.
4. Run scripts/check.sh. Never finish with a failing check.
5. Ask the reviewer subagent to review your diff. Fix what it finds.
6. Open a pull request using the template. Tick every acceptance check.
7. When PR review comments arrive, fix them, push, reply on each thread
   explaining what you changed (or why no change was needed), then resolve the thread.
8. If a task needs a real phone (blocking, overlays, Device admin, browsers),
   add the exact steps to docs/testing/device-checklist.md and say so in the PR.

## Architecture rules (never break these)
- Feature code lives in lib/features/<feature>/{data,application,presentation}.
- presentation may import application; application may import data and policy;
  nothing imports presentation. policy/ imports only Dart and approved packages.
- lib/policy/ and android/rules-engine/ stay PURE: no Flutter, no Android APIs.
- Kotlin enforces blocking on its own from the rules snapshot. Dart is the source of
  truth for settings and pushes a new snapshot after every change.
- All Dart <-> Kotlin calls go through pigeons/blocker_api.dart. No raw MethodChannel.
- Time for limits and the 24-hour wait comes from the monotonic clock, never the wall clock.
- No network calls. No analytics. No data leaves the phone.

## Business rules you must enforce in code
- Stricter changes apply instantly. Weaker changes need approval only in strict mode.
- Approval = valid partner TOTP code OR a finished 24-hour wait. One approval = one change.
- 5 wrong codes -> 15-minute lockout. Phone, SMS, emergency, launcher, this app: never blockable.
- See FRD section 2 for the full list.

## Code style
- Dart: very_good_analysis, no warnings. Kotlin: ktlint clean.
- Small files (under ~300 lines). Clear names over comments.
- Generated files (*.g.dart, *.freezed.dart, pigeon output) are committed.
  After changing a model or the pigeon file, run scripts/gen.sh.
- User-facing text: short plain English, kept in lib/shared/strings.dart.

## Testing
- policy/ and rules-engine/: 95%+ line coverage, every FRD rule has a test.
- Repositories and controllers: unit tests with fakes. Screens: widget tests for main states.
- Kotlin services: Robolectric tests. Shared cases live in test_vectors/ (JSON).

## Never
- Never edit generated files by hand, or files in docs/product/ (those are the client's).
- Never add a dependency without an ADR in docs/adr/.
- Never request a permission without its disclosure screen (see docs/play/).
- Never say the app treats addiction, or that strict mode is impossible to bypass.
- Never push to main, force-push, or skip checks.

## Commands
- scripts/check.sh    format + analyze + Dart tests + Kotlin tests
- scripts/gen.sh      code generation
- flutter test test/path/to_test.dart   one test file
