# ADR 0003: Monotonic clock for waits and limits

## Status
Accepted

## Context
Users might change the phone's wall clock to cheat on the 24-hour wait or
daily limits. The app must be tamper-resistant.

## Decision
Waits and limits use a monotonic clock that sums elapsed time across reboots.
Time while the phone is switched off is not counted, so a 24-hour wait can
take longer if the phone is off. The app says this on screen.

## Consequences
- Changing the wall clock does not affect waits or limits.
- A 24-hour wait might take longer than 24 real hours if the phone is off.
- The monotonic clock module must survive reboots by persisting its state.
- The UI must explain this behaviour to the user.
