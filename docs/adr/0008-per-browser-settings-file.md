# ADR 0008: Per-browser settings file for URL bar reading

## Status
Accepted

## Context
Website blocking requires reading the URL from the browser's address bar via
the accessibility service. Each browser has a different view ID for its URL
bar, and browsers update frequently.

## Decision
Browser address bars are read using a per-browser settings file
(`browsers.json`), mapping each supported browser's package name to its URL
bar accessibility node ID. When a browser updates its layout, only the data
file needs to change.

## Consequences
- Supporting a new browser or handling a browser update is a data change, not
  a code change.
- The settings file must be tested with each supported browser version.
- Unsupported browsers silently skip website blocking (app blocking still works).
- The file is bundled with the app and can be updated in an app release.
