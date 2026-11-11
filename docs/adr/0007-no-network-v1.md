# ADR 0007: No network, analytics or crash reporting in the first version

## Status
Accepted

## Context
The app's privacy promise says no data leaves the phone. Adding analytics
or crash reporting would break this promise.

## Decision
The first version makes no network calls. No analytics, no crash reporting,
no cloud backup. Use Play Console vitals for crash data instead.

## Consequences
- The privacy promise is easy to verify: no INTERNET permission.
- Crash reporting relies on Play Console vitals (less detailed).
- Cloud backup and server-side payment verification come in a later version.
- The app works fully offline with no account or login.
