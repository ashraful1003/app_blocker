# pr-review

Review a pull request from multiple angles and post findings as a GitHub review.

Usage: `/pr-review <PR number>`

## Steps

### 1. Gather context

- Fetch the PR: title, description, diff, changed files, commits.
- Identify the task card from the PR description (`docs/tasks/T-*.md`).
- Read the task card, the FRD sections it cites, and any relevant ADRs.
- Read every changed file in full (not just the diff hunks).

### 2. Run review passes

Run these passes in parallel using forks. Each fork reviews the full diff
and changed files from its own angle and returns a list of findings.

#### Pass A — Correctness

- Logic bugs, off-by-one errors, null/empty edge cases.
- Unreachable code, dead branches, swapped conditions.
- Missing error handling at system boundaries.
- Dart exhaustiveness: does every switch cover all cases?
- Kotlin: are nullability annotations correct?

#### Pass B — Security

- OWASP Mobile Top 10: injection, insecure storage, broken auth.
- Data leakage: does anything leave the device? (violates CLAUDE.md)
- Permission scope: is anything requested beyond what's needed?
- Timing attacks on TOTP or approval logic.
- Clock manipulation: is monotonic clock used for limits/waits? (CLAUDE.md rule)
- Input validation at all boundaries (user input, Pigeon bridge, intents).
- Secrets in code: API keys, hardcoded credentials, signing info.

#### Pass C — Architecture compliance

- Layer imports: presentation → application → data/policy only.
- policy/ and rules-engine/ are pure: no Flutter, no Android APIs.
- Dart ↔ Kotlin through Pigeon only, no raw MethodChannel.
- Feature code in lib/features/<name>/{data,application,presentation}.
- No network calls, no analytics.
- New dependency has an ADR in docs/adr/.
- Generated files not edited by hand.
- Files under ~300 lines.

#### Pass D — Spec compliance

- Every acceptance check on the task card is met by the code.
- FRD business rules enforced: stricter=instant, weaker=approval in strict mode.
- Never-blockable apps list respected (phone, SMS, emergency, launcher, this app).
- One approval = one change.
- 5 wrong codes → 15-min lockout.
- Streak resets on weaker change or protection disabled.

#### Pass E — Test quality

- New/changed logic has tests.
- policy/ and rules-engine/ maintain 95%+ coverage target.
- Tests describe behaviour, not implementation.
- Shared logic has test vectors in test_vectors/.
- Edge cases covered: empty inputs, boundary values, overflow.

#### Pass F — Style and docs

- Dart: very_good_analysis clean (no warnings, infos are acceptable).
- Kotlin: ktlint clean.
- Clear names, no unnecessary comments.
- User-facing text in lib/shared/strings.dart.
- Docs updated if behaviour or a decision changed.
- PR description follows the template and ticks acceptance checks.

### 3. Deduplicate and rank

- Merge findings from all passes, removing duplicates.
- Assign severity:
  - **blocker**: security vulnerability, data leak, broken business rule, crash.
  - **must-fix**: logic bug, missing test for new logic, architecture violation.
  - **suggestion**: style nit, minor improvement, optional refactor.
- Sort: blockers first, then must-fix, then suggestions.

### 4. Post the review

Post findings as a GitHub PR review using the MCP tools:

1. Create a pending review (`pull_request_review_write` method `create`).
2. For each finding with a specific file and line, add an inline comment
   (`add_comment_to_pending_review`) with this format:
   ```
   **[severity]** category — summary

   file:line — description

   Suggested fix: ...
   ```
3. Submit the review (`pull_request_review_write` method `submit_pending`):
   - If any blockers or must-fixes: submit as **REQUEST_CHANGES** with a
     summary listing the count of each severity.
   - If only suggestions or no findings: submit as **COMMENT** with a summary.

The review body should start with a summary table:

```
## PR Review Summary

| Category | Blockers | Must-fix | Suggestions |
|----------|----------|----------|-------------|
| Correctness | 0 | 0 | 0 |
| Security | 0 | 0 | 0 |
| Architecture | 0 | 0 | 0 |
| Spec compliance | 0 | 0 | 0 |
| Test quality | 0 | 0 | 0 |
| Style & docs | 0 | 0 | 0 |

(details in inline comments)
```

End the review body with the attribution footer.

### 5. Report to the user

Print a one-paragraph summary: how many findings at each severity, the top
concern if any, and whether the PR is ready to merge.
