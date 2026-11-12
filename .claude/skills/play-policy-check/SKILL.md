# play-policy-check

Check permissions, disclosures and text against Google Play rules and the SRS.

## When to run

- Any change to AndroidManifest.xml or permissions.
- Any change to disclosure screens or store text.
- Before any release.

## Steps

1. Read `android/app/src/main/AndroidManifest.xml`.
2. For each permission declared:
   - Confirm there is a matching disclosure screen in `lib/features/onboarding/`.
   - Confirm the disclosure text matches SRS section 6 and `docs/play/`.
3. Check that no user-facing text:
   - Claims the app treats addiction.
   - Says strict mode is "impossible to bypass" (use "hard to cheat" instead).
4. Check that Accessibility usage matches the declared purpose (detecting app launches
   and reading browser URLs).
5. Check that Device admin usage matches the declared purpose (preventing uninstall
   in strict mode).
6. Report pass/fail per item, with the rule it breaks if it fails.
7. If running before a release, also verify:
   - Privacy form states no data is collected.
   - Accessibility declaration video script matches actual behaviour.
