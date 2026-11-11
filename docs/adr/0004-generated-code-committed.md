# ADR 0004: Generated code is committed and checked for freshness in CI

## Status
Accepted

## Context
The project uses code generation (build_runner, freezed, pigeon). Generated
files could be left out of version control, but that means every developer and
CI run must regenerate them.

## Decision
Generated code (*.g.dart, *.freezed.dart, pigeon output) is committed to the
repository. CI runs `scripts/gen.sh` and fails if `git diff` shows changes,
ensuring the committed generated code matches the source.

## Consequences
- Cloning the repo gives you a buildable project immediately.
- Pull request diffs show what actually changed in generated code.
- Developers must run `scripts/gen.sh` after changing models or the pigeon file.
- CI catches stale generated code before it reaches main.
