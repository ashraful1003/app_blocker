# native-bridge

Add a new Dart ↔ Kotlin call through Pigeon.

## Steps

1. Edit `pigeons/blocker_api.dart` to add the new API method or class.
2. Run `scripts/gen.sh` to regenerate the bridge code on both sides.
3. Implement the Kotlin host API in `android/app/src/main/kotlin/app/blocker/bridge/`.
4. Add a thin Dart wrapper in `lib/platform/` that calls the generated Pigeon class.
5. Create a fake of the wrapper in `test/` for use in Dart tests.
6. Write a Robolectric test for the Kotlin host in `android/app/src/test/`.
7. Add a device-checklist entry in `docs/testing/device-checklist.md` if the call
   interacts with the OS (accessibility, device admin, services).
8. Run `scripts/check.sh`.
