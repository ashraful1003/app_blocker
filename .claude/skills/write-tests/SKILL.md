# write-tests

Write or update tests for a logic change.

## Naming

- Test files mirror the source: `lib/policy/foo.dart` → `test/policy/foo_test.dart`.
- Test names describe behaviour: `'returns blocked when schedule is active'`.
- Group related tests with `group()`.

## Fakes over mocks

- Prefer hand-written fakes over generated mocks.
- Only use `mocktail` when faking would require too much boilerplate.

## Shared test vectors

- For logic shared between Dart and Kotlin (the rules snapshot), add cases to
  `test_vectors/` as JSON files.
- Each JSON file has an array of `{ input, expected }` objects.
- Both the Dart and Kotlin test suites read and assert against these files.

## Coverage targets

- `lib/policy/`: 95%+ line coverage.
- `android/rules-engine/`: 95%+ line coverage.
- Every FRD main rule must have at least one test.

## Running

- Single file: `flutter test test/path/to_test.dart`
- All Dart: `flutter test`
- Kotlin rules-engine: `cd android && ./gradlew :rules-engine:test`
- Everything: `scripts/check.sh`
