# Device Testing Checklist

Manual tests that must pass on real phones before closing a milestone.
Test on at least two brands (ideally Samsung and Xiaomi).

## Phones used

| Brand | Model | Android version | Notes |
|-------|-------|-----------------|-------|
| _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| _TBD_ | _TBD_ | _TBD_ | _TBD_ |

## M0 — Harness

- [ ] Debug APK from CI installs and opens on both phones.
- [ ] The app shows "App Blocker" text on the main screen.

## M2 — Blocking on the phone

_Steps will be added when M2 tasks are built._

## M3 — Main screens

_Steps will be added when M3 tasks are built._

## M4 — Strict mode and partner

_Steps will be added when M4 tasks are built._

## How to add a step

When a task card says "Device test needed: Yes", add the exact steps here
under the relevant milestone heading. Format:

```
- [ ] Description of what to do and what to expect.
      Task: T-MX-NN. Tested on: [brand, date].
```
