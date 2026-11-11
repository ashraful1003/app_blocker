# ADR 0006: Accessibility service for detection, native Activity for block screen

## Status
Accepted

## Context
The app needs to detect when a blocked app launches and show a block screen
within 1 second. There are two Android mechanisms: UsageStatsManager (polling)
and AccessibilityService (event-driven).

## Decision
App launches are detected with the accessibility service, which fires events
immediately. The block screen is a native Activity built with Jetpack Compose,
so it appears within 1 second without needing to start the Flutter engine.

## Consequences
- Block screen appears fast because it is a lightweight native Activity.
- The accessibility service also reads browser URL bars for website blocking.
- Google Play requires a disclosure form and video for accessibility usage.
- The app must clearly explain to the user why accessibility is needed.
