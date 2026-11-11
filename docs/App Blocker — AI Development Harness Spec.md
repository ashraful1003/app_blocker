# App Blocker — AI Development Harness Spec

&#32;Version 1.0 · Nov 11, 2026 · @License9

## 1. What this document is

This is the blueprint for the **harness**: the set of files, rules and automatic checks that let a Claude agent build App Blocker safely and in small steps. The agent reads this spec, creates the harness first, and only then starts building features.

The harness has six parts:

1. **A rulebook** (`CLAUDE.md`) that tells the agent how this project works.
2. **Project knowledge** in `docs/`: the SRS, the FRD, the architecture and recorded decisions.
3. **A fixed structure** for folders and code, so every feature looks the same.
4. **Automatic checks** (format, lint, tests, build) that run on every change and in GitHub Actions.
5. **Skills and helper agents** for repeated jobs, such as adding a feature or reviewing code.
6. **A task plan** split into small task cards the agent works through one at a time.

### How to use it

1. Create an empty private GitHub repository, for example `app-blocker`.
2. Export the SRS and FRD docs as Markdown. You'll add them to the repo as `docs/product/SRS.md` and `docs/product/FRD.md`.
3. Export this spec as Markdown too, as `docs/harness-spec.md`.
4. Commit those three files to the repo.
5. Start a Claude Code cloud session on the repo and paste the kickoff prompt from section 11.
6. Review and merge the agent's first pull request. That PR is the harness. Feature work starts after it.

## 2. Facts that shape the harness

| Fact | What it means for the harness |
| --- | --- |
| One developer (you) directs Claude Code. | Small task cards, one pull request each, so you can review quickly. A reviewer subagent does a first review before you. |
| Claude Code runs in **cloud sessions**. | There is no phone or emulator in the session. The agent proves its work with automated tests. GitHub Actions builds an APK you install on a real phone. |
| Code lives on **GitHub**. | GitHub Actions runs every check on each pull request. The `main` branch only accepts green pull requests. |
| The app is Flutter **plus** native Kotlin. | Screens and business rules are Dart. Blocking, overlays, Device admin and Accessibility are Kotlin. The harness needs checks for both. |
| Blocking must work even when the Flutter app is closed. | The Kotlin side enforces rules on its own, from a copy of the rules that Dart sends it. |
| The riskiest logic is pure rules (schedules, limits, approval codes, the 24-hour wait, streak). | That logic lives in plain Dart with no Flutter or Android code, so it can be tested fully in the cloud. |
| Google Play reviews Accessibility apps closely. | A skill and a subagent check every permission and disclosure against the SRS before release. |

## 3. Tech stack decisions

These choices are final for the first version. The agent must not add or swap a library without a recorded decision (section 11).

| Area | Choice | Why |
| --- | --- | --- |
| Flutter | Latest stable at project start, pinned to an exact version in `pubspec.yaml` | Same version in cloud sessions, CI and on your machine |
| Language level | Dart 3 with strict analysis | Catches mistakes before tests run |
| State management | Riverpod with code generation (`flutter_riverpod`, `riverpod_generator`) | Testable, no global state, widely known by AI models |
| Navigation | `go_router` | Standard, supports redirects for onboarding and permissions |
| Data models | `freezed` + `json_serializable` | Immutable models, safe copies, JSON for the rules snapshot |
| Local database (Dart) | `drift` with `sqlcipher_flutter_libs` (encrypted SQLite) | Typed queries, migrations, encryption, easy to test in memory |
| Secrets (Dart) | `flutter_secure_storage` | Keeps the database key and partner secret in Android Keystore |
| Flutter ↔ Kotlin bridge | `pigeon` | Generates type-safe code on both sides; no hand-written channel strings |
| Approval codes | Own small TOTP module (RFC 6238) using the `crypto` package | A few dozen lines; tested against the official RFC test values |
| QR code for partner setup | `qr_flutter` | Simple and maintained |
| Charts (stats) | `fl_chart` | Covers bars, lines and the weekly heatmap |
| Payments | `in_app_purchase` | Official Flutter plugin for Google Play Billing |
| Dart lint | `very_good_analysis` | Strict rule set; keeps AI-written code consistent |
| Dart tests | `flutter_test`, `mocktail` | Standard; no code generation for mocks |
| Native language | Kotlin, min SDK 26, coroutines | Required for Accessibility, Device admin and services |
| Native storage | Rules snapshot as an encrypted file (Google Tink); native events in Room | Readable by the service when Flutter isn't running |
| Native block screen | Small native Activity built with Jetpack Compose | Appears within 1 second without starting Flutter |
| Kotlin lint | ktlint (Gradle plugin) | One style, auto-fixable |
| Kotlin tests | JUnit, MockK, Robolectric | Runs on the JVM, so it works in the cloud and in CI |
| CI | GitHub Actions | Free for private repos within limits; builds APKs you can download |
| Crash reporting | None in the first version | The privacy promise says no data leaves the phone; use Play Console vitals instead |

## 4. Architecture

&#91;embedded content: app architecture · Flutter side, bridge, Kotlin side\]

Dart owns the settings and decides what needs approval. After every change it sends Kotlin a full rules snapshot. Kotlin stores that copy and blocks from it on its own, even when the Flutter app is closed. Kotlin records each urge, and Dart collects those events when the app opens.

## 5. Repository structure

Every feature uses the same three layers, so the agent always knows where code goes. The package name `app.blocker` is a placeholder until the final app name is chosen.

```text
app-blocker/
├── CLAUDE.md                     # the agent's rulebook (section 6)
├── README.md                     # how a human sets up and runs the project
├── .claude/
│   ├── settings.json             # allowed commands + hooks (section 7)
│   ├── hooks/                    # small scripts the hooks call
│   ├── skills/                   # new-feature, native-bridge, write-tests, play-policy-check, next-task
│   └── agents/                   # reviewer.md, play-policy-auditor.md
├── .github/
│   ├── workflows/                # pr.yml, nightly.yml, release.yml
│   └── pull_request_template.md
├── scripts/
│   ├── setup_cloud.sh            # installs Flutter, Java, Android SDK in a cloud session
│   ├── check.sh                  # ONE command for every local check
│   └── gen.sh                    # runs build_runner and pigeon
├── docs/
│   ├── harness-spec.md           # this document
│   ├── product/                  # SRS.md, FRD.md
│   ├── architecture.md
│   ├── adr/                      # decision records: 0001-…, 0002-…
│   ├── tasks/                    # backlog.md + one card per task
│   ├── testing/device-checklist.md
│   └── play/                     # disclosure texts, Accessibility declaration notes
├── pigeons/
│   └── blocker_api.dart          # the bridge contract between Dart and Kotlin
├── lib/
│   ├── main.dart
│   ├── app/                      # router, theme, startup
│   ├── policy/                   # PURE DART: stricter vs weaker, TOTP, 24-hour wait, streak
│   ├── features/
│   │   ├── onboarding/
│   │   ├── blocklist/            # apps and websites
│   │   ├── schedules/
│   │   ├── limits/
│   │   ├── strict_mode/
│   │   ├── partner/
│   │   ├── stats/
│   │   └── premium/
│   │       ├── data/             # repositories, drift tables, platform calls
│   │       ├── application/      # Riverpod controllers and use cases
│   │       └── presentation/     # screens and widgets
│   ├── platform/                 # generated pigeon code + a thin wrapper
│   └── shared/                   # common widgets, strings, utilities
├── test/                         # mirrors lib/ one-to-one
└── android/
    ├── rules-engine/             # PURE KOTLIN (JVM): is this app or site blocked right now?
    └── app/src/
        ├── main/kotlin/app/blocker/
        │   ├── bridge/           # pigeon host implementation
        │   ├── accessibility/    # accessibility service, browser URL reader, browsers.json
        │   ├── enforcement/      # foreground service, boot receiver
        │   ├── block/            # block screen Activity
        │   ├── admin/            # Device admin receiver
        │   ├── store/            # encrypted rules snapshot, Room event database
        │   └── time/             # monotonic clock that survives reboots
        └── test/                 # JVM tests (JUnit, MockK, Robolectric)
```

**Two pure modules carry the risky logic.** `lib/policy/` (Dart) decides what needs approval. `android/rules-engine/` (Kotlin) decides what is blocked right now. Neither touches Flutter or Android APIs, so both are fully testable in a cloud session.

## 6. CLAUDE.md (the agent's rulebook)

The agent creates this file at the repo root, word for word, then keeps it under 200 lines. Long details live in `docs/` and are linked, not copied.

```markdown
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
7. If a task needs a real phone (blocking, overlays, Device admin, browsers),
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
```

## 7. Claude Code configuration

All of this lives in `.claude/` and is committed, so every cloud session behaves the same.

### Permissions (`.claude/settings.json`)

- **Allow without asking:** `flutter`, `dart`, `./gradlew` inside `android/`, everything in `scripts/`, read-only `git` commands, `git add`, `git commit`, `git checkout -b`, `git push` to `task/*` branches, `gh pr create`, `gh pr view`.
- **Deny:** reading or writing `*.jks`, `*.keystore`, `key.properties`, `.env*`; `git push` to `main`; `git push --force`; `rm -rf` outside `build/`.

### Hooks

Hooks are small scripts in `.claude/hooks/` that run automatically at set moments.

| When | What it does | Why |
| --- | --- | --- |
| Session start | Runs `scripts/setup_cloud.sh` if Flutter is missing (it is safe to run twice) | Every cloud session starts ready to work |
| Before a file edit | Refuses edits to generated files (`*.g.dart`, `*.freezed.dart`, pigeon output) and to `docs/product/` | Generated code comes from `gen.sh`; the SRS and FRD belong to the client |
| Before a shell command | Refuses force-push, pushes to `main`, and `rm -rf` outside build folders | Protects history and the repo |
| After a file edit | Formats the file: `dart format` for Dart, `ktlint -F` for Kotlin | Style never becomes a review topic |
| Before the agent finishes | Runs the fast checks (analyze + tests for changed code). If they fail, the agent must keep working | The agent can't stop with broken code. The script checks the hook's "already active" flag so it can't loop forever |

### Skills (`.claude/skills/`)

Each skill is a folder with a `SKILL.md` describing one repeatable job, step by step.

| Skill | When the agent uses it | What it covers |
| --- | --- | --- |
| `next-task` | Starting work | Picks the first card in `docs/tasks/backlog.md` whose dependencies are done, creates the branch, writes a short plan in the PR draft |
| `new-feature` | Adding a feature folder | Creates `data/`, `application/`, `presentation/`, a route, a controller with a test, and a screen with a widget test |
| `native-bridge` | Any new Dart ↔ Kotlin call | Edit `pigeons/blocker_api.dart` → run `gen.sh` → implement the Kotlin host → add a Dart wrapper + a fake for tests → Robolectric test → device checklist entry |
| `write-tests` | Any logic change | Test naming, fakes over mocks, how to add a shared case to `test_vectors/`, coverage targets |
| `play-policy-check` | Any change to permissions, disclosures, store text or before a release | Checks the manifest, disclosure screens and text against Google Play rules and SRS section 6 |

### Helper agents (`.claude/agents/`)

Both have read-only tools, so they can review but never change code.

| Agent | Job | Output |
| --- | --- | --- |
| `reviewer` | Reviews the branch diff against `CLAUDE.md`, the architecture rules, the task card's acceptance checks and test quality | A list of must-fix and nice-to-fix items, with file and line |
| `play-policy-auditor` | Checks the manifest, permission flows, disclosure texts and any store or in-app text for medical claims or "impossible to bypass" wording | Pass or fail per item, with the rule it breaks |

## 8. Quality gates and testing

Nothing reaches `main` unless every automatic check is green. The same checks run in three places: after each edit (hooks), on demand (`scripts/check.sh`), and on every pull request (GitHub Actions).

### `scripts/check.sh`

One command, stops at the first failure:

1. `dart format --set-exit-if-changed .`
2. `flutter analyze` with zero warnings
3. Generated-code check: run `scripts/gen.sh`, then fail if `git diff` shows changes
4. `flutter test --coverage`, then fail if `lib/policy/` is under 95% line coverage
5. `./gradlew ktlintCheck :rules-engine:test` (pure Kotlin, needs no Android SDK)
6. `./gradlew :app:testDebugUnitTest` (Robolectric). If the Android SDK isn't installed in the session, print a clear warning and leave this to CI

### GitHub Actions workflows

| Workflow | Runs when | What it does |
| --- | --- | --- |
| `pr.yml` | Every pull request and push to `main` | Job 1: Dart checks (steps 1–4). Job 2: Kotlin checks (steps 5–6). Job 3: builds a debug APK and attaches it to the run so you can install it on a phone |
| `nightly.yml` | Every night, from milestone M2 onward | Starts an Android emulator, installs the APK, turns on the accessibility service with `adb`, opens a blocked app and checks the block screen appears |
| `release.yml` | When you push a tag like `v0.1.0` | Builds a signed release bundle (AAB) using signing keys stored as GitHub secrets |

### Branch protection on `main`

- Changes only through pull requests; no direct pushes.
- `pr.yml` must pass before merging.
- Squash merge only, so each task is one commit in history.

### Testing strategy

| Layer | What is tested | Tool | Where it runs |
| --- | --- | --- | --- |
| Policy (Dart) | Stricter vs weaker, TOTP codes, lockout, 24-hour wait, streak resets | `flutter test` | Cloud session + CI |
| Rules engine (Kotlin) | Schedules incl. overnight and time zones, daily limits, website matching, never-blockable apps | JUnit | Cloud session + CI |
| Snapshot contract | Dart writes the rules snapshot; Kotlin reads it and gets the expected result | Shared JSON cases in `test_vectors/` at the repo root, run by both test suites | Cloud session + CI |
| Repositories and controllers | Saving settings, pushing the snapshot, approval flows | `flutter test` with fakes | Cloud session + CI |
| Screens | Main states of each screen (empty, filled, error, locked) | Widget tests | Cloud session + CI |
| Kotlin services | Accessibility event handling, boot restart, browser URL reading | Robolectric | CI (cloud if the SDK installs) |
| End to end | Block screen appears on a blocked app | Emulator in `nightly.yml` | CI |
| Real phones | Battery killers, Device admin, browsers, strict mode, reboot | Manual steps in `docs/testing/device-checklist.md` | You, on real phones, before closing each milestone |

The TOTP module is tested against the official test values published in RFC 6238, so partner codes match Google Authenticator exactly.

## 9. Cloud environment setup

A cloud session starts as a bare Linux machine. `scripts/setup_cloud.sh` makes it ready, and is safe to run again.

### What the script must do

1. Read the pinned Flutter version from `pubspec.yaml` and install exactly that version, skipping if it's already there.
2. Run `flutter pub get` and `flutter precache --android`.
3. Make sure Java 17 is installed.
4. Install the Android command-line tools, platform tools, the platform and build tools matching `compileSdk`, and accept the licences.
5. Set `ANDROID_HOME` and `PATH` for later commands.
6. Run `flutter doctor` and print a short summary of what works.
7. If any Android step fails, keep going, mark the session "Dart-only", and let `check.sh` skip step 6 with a warning. CI still runs everything.

### What you set once in Claude Code (web) environment settings

- **Setup script:** `bash scripts/setup_cloud.sh`.
- **Network access:** allow these domains, or choose the wider access level if a domain list isn't offered:
  - `github.com`, `storage.googleapis.com` (Flutter SDK)
  - `pub.dev`, `pub.dartlang.org` (Dart packages)
  - `dl.google.com`, `maven.google.com` (Android SDK and Android Gradle plugin)
  - `repo.maven.apache.org`, `plugins.gradle.org`, `services.gradle.org` (Gradle)
- **Secrets:** none. Signing keys live only in GitHub Actions secrets, never in sessions.

The first harness task tests this script in a real cloud session and records what worked in `docs/environment.md`.

## 10. Workflow, milestones and task cards

### The daily loop

1. You open a cloud session and say: "Start the next task."
2. The agent uses `next-task`, reads the card, and creates a branch.
3. It writes tests, then code, then runs `scripts/check.sh` until green.
4. The `reviewer` agent reviews the diff; the agent fixes must-fix items.
5. The agent opens a pull request. GitHub Actions runs `pr.yml`.
6. If the card needs a device test, you download the APK from the run and follow the checklist steps on your phone.
7. You merge. Next task.

### Definition of done (every task)

- [ ] Every acceptance check on the card is met and ticked in the PR.
- [ ] New or changed logic has tests; coverage targets still hold.
- [ ] `scripts/check.sh` and `pr.yml` are green.
- [ ] The reviewer agent has no open must-fix items.
- [ ] Device steps are added to the checklist, when the card needs them.
- [ ] Docs are updated when behaviour or a decision changed (`architecture.md`, an ADR).

### Milestones

| Milestone | What gets built | FRD features | Finished when |
| --- | --- | --- | --- |
| M0 Harness | Everything in this spec, plus an empty app that builds | — | `pr.yml` green; the debug APK installs and opens on your phone |
| M1 Rules core | `lib/policy/`, `android/rules-engine/`, the snapshot format, `test_vectors/` | Logic of FR-03, 04, 07, 08, 09, 13 and FRD main rules | Coverage targets met; every main rule has a test |
| M2 Blocking on the phone | Pigeon bridge, accessibility service, block screen, foreground service, boot restart, encrypted snapshot store, monotonic clock, browser URL reader | FR-05, FR-11, FR-13 (blocking part) | Device checklist passes on 2 phone brands; nightly emulator test green |
| M3 Main screens | Onboarding, permissions, battery setup, app picker, websites, schedules, limits, home | FR-01, 02, 03, 04, 06, 13 | Widget tests green; device checklist passes |
| M4 Strict mode and partner | Device admin, settings blocking, partner setup with QR, approval screen, 24-hour wait | FR-07, 08, 09 | Uninstall attempt, clock change and reboot tests pass on a phone |
| M5 Stats and streak | Urges collected from Kotlin, time saved, streak, weekly summary, CSV export | FR-10 | Numbers match a scripted test day |
| M6 Premium | Google Play Billing, paywall, trial, offline entitlement, expiry rule | FR-12 | Test purchases work in Play's internal testing track |
| M7 Hardening and release | Brand battery guides, disclosures review, policy audit, Accessibility declaration video, privacy form, signed release | NFRs, SRS section 6 | `play-policy-auditor` passes; app live in closed testing |

### Task cards

During M0 the agent writes all M1 cards. At the start of each later milestone it writes that milestone's cards, and you approve them before work starts. Each card is small: about half a day of agent work and one pull request.

```markdown
# T-M1-03 Schedule evaluation with overnight windows
Milestone: M1 · Depends on: T-M1-01 · FRD: FR-03, main rule 7

## Goal
The rules engine says whether a schedule is active at a given local time.

## In scope / out of scope
In: days of week, overnight windows, time zone changes. Out: daily limits (T-M1-04).

## Files likely touched
android/rules-engine/src/main/kotlin/.../ScheduleEvaluator.kt (+ tests), test_vectors/schedules/*.json

## Acceptance checks
- [ ] 22:00–07:00 weekdays: active Fri 23:30, inactive Sat 07:00, not started Sat 22:00
- [ ] Next window follows a new time zone
- [ ] Shared snapshot cases in test_vectors/ pass in the Kotlin suite and round-trip in the Dart suite

## Device test needed
No
```

## 11. Decisions, open items and kickoff

### Decisions to record as ADRs in M0

Each ADR is a short file in `docs/adr/`: the decision, why, and what was rejected.

| ADR | Decision |
| --- | --- |
| 0001 | Flutter for screens and business rules; Kotlin for enforcement. |
| 0002 | Kotlin alone decides "blocked right now". Dart owns settings and approval rules, and pushes a rules snapshot through Pigeon after every change. Dart asks Kotlin for live status. |
| 0003 | Waits and limits use a monotonic clock summed across reboots. Time while the phone is switched off is not counted, so a 24-hour wait can take longer if the phone is off. The app says this on screen. |
| 0004 | Generated code is committed and checked for freshness in CI. |
| 0005 | TOTP is our own small module, tested against RFC 6238 values. |
| 0006 | App launches are detected with the accessibility service; the block screen is a native Activity. |
| 0007 | No network, analytics or crash reporting in the first version. |
| 0008 | Browser address bars are read using a per-browser settings file (`browsers.json`), so a browser update only needs a data change. |

### Open items for you

- [ ] Final app name and package ID (needed before M7; `app.blocker` until then).
- [ ] Create the release signing key and add it to GitHub secrets (before M7). The agent writes the steps for you in M0.
- [ ] Google Play developer account in the client's name.
- [ ] At least two test phones from different brands, ideally Samsung and Xiaomi.
- [ ] Set up the cloud environment as in section 9.
- [ ] Optional: install the Claude GitHub app, so you can ask `@claude` for changes on a pull request.

### Kickoff prompt

Paste this into the first cloud session, once the repo holds the three docs from section 1.

```text
You are setting up the development harness for App Blocker. Do not build any app
features yet.

Read docs/harness-spec.md fully, then docs/product/SRS.md and docs/product/FRD.md.

Complete milestone M0 exactly as the spec describes:
1. Create a Flutter app (Android only) with the folder structure in section 5,
   pinned to the latest stable Flutter, package ID app.blocker, min SDK 26.
2. Add CLAUDE.md from section 6 word for word.
3. Add .claude/settings.json, hooks, the five skills and two helper agents from section 7.
4. Add scripts/setup_cloud.sh, check.sh and gen.sh, and the three GitHub workflows,
   branch-protection notes and PR template from section 8.
5. Add an empty pure-Kotlin Gradle module android/rules-engine/ with one passing test,
   and an empty lib/policy/ with one passing test.
6. Write docs/architecture.md, ADRs 0001-0008 from section 11, docs/environment.md
   (what setup_cloud.sh managed to install here), docs/testing/device-checklist.md,
   and the signing-key steps for me.
7. Write docs/tasks/backlog.md and one card per task for milestone M1, using the card
   format in section 10. Do not start them.
8. Run scripts/check.sh until green.

Work on branch task/M0-harness and open one pull request. In the description, list
anything from the spec you could not do in this session, and why.
```
