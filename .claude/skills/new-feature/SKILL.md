# new-feature

Scaffold a new feature folder with the standard three-layer structure.

## Steps

1. Choose the feature name (e.g. `blocklist`).
2. Create the folder structure:
   ```
   lib/features/<feature>/
   ├── data/          # repositories, drift tables, platform calls
   ├── application/   # Riverpod controllers and use cases
   └── presentation/  # screens and widgets
   ```
3. Create a minimal controller in `application/` with a Riverpod provider.
4. Create a minimal screen in `presentation/` that reads from the controller.
5. Add a route in `lib/app/router.dart` (when it exists).
6. Create a unit test for the controller in `test/features/<feature>/application/`.
7. Create a widget test for the screen in `test/features/<feature>/presentation/`.
8. Run `scripts/check.sh` to make sure everything compiles and passes.
