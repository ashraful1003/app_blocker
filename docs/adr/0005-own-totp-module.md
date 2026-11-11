# ADR 0005: Own small TOTP module tested against RFC 6238

## Status
Accepted

## Context
Partner approval uses TOTP codes. We could use an existing TOTP library or
write our own.

## Decision
We write a small TOTP module (a few dozen lines) using the `crypto` package.
It is tested against the official test values published in RFC 6238, so codes
match Google Authenticator exactly.

## Consequences
- No external TOTP dependency to audit or keep updated.
- The module is small enough to review completely.
- RFC 6238 test vectors prove compatibility with standard authenticator apps.
- If the TOTP standard changes, we update one small module.
