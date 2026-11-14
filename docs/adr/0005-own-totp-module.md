# ADR 0005: Own small TOTP module tested against RFC 6238

## Status
Accepted

## Context
Partner approval uses TOTP codes. We could use an existing TOTP library or
write our own.

## Decision
We write a small TOTP module (a few dozen lines) using the `crypto` package.
It is tested against the official test values published in RFC 6238, so codes
match Google Authenticator exactly. The module also includes a small RFC 4648
base32 decoder, since authenticator apps show and scan the shared secret as
base32 text, not as raw key bytes — the module decodes it before computing
codes. The decoder is tested against the RFC 4648 test vectors directly, in
addition to the RFC 6238 TOTP vectors (re-expressed with a base32 secret).

## Consequences
- No external TOTP or base32 dependency to audit or keep updated.
- The module is small enough to review completely.
- RFC 6238 and RFC 4648 test vectors prove compatibility with standard
  authenticator apps, including the base32 secret format they use.
- If the TOTP standard changes, we update one small module.
