# AI Rules

- Avoid ls -R: Never use ls -R for exploring the project structure as it produces excessively large outputs that consume many tokens.

## Project Overview

- This repository is a multi-package Dart codebase for compile-time dependency injection.
- `knife_annotations` contains the public annotation API.
- `knife_generator` contains the `source_gen` / `build_runner` generator implementation.
- `knife_generator/example` is a Flutter sample app that consumes the local packages.
- `AI_RULES.md` is the canonical source of truth for AI agents in this repository.

## Repo Layout

- `knife_annotations/`
  - Standalone Dart package.
  - Public API is defined in `lib/knife_annotations.dart`.
- `knife_generator/`
  - Standalone Dart package.
  - Public builders live in `lib/`.
  - Internal generator implementation lives in `lib/src/`.
  - Tests live in `test/`.
- `knife_generator/example/`
  - Standalone Flutter app package.
  - Demonstrates generated `.component.dart` and `.module.dart` outputs.
- Run commands from the package directory they belong to, not from repo root.

## Commands

### `knife_annotations`

- Install: `dart pub get`
- Analyze: `dart analyze`

### `knife_generator`

- Install: `dart pub get`
- Analyze: `dart analyze`
- Test: `dart test`

### `knife_generator/example`

- Install: `flutter pub get`
- Analyze: `flutter analyze`
- Codegen: `dart run build_runner build`
- Codegen with overwrite: `dart run build_runner build --delete-conflicting-outputs`

## Other

- Use `InvalidGenerationSourceError` for generator validation failures.

## Dependency Conflict Resolution (Analyzer/Meta Conflict)

When encountering dependency conflicts where a package (e.g., `analyzer`) requires a newer version of a core package (e.g., `meta`) than the one pinned by the Flutter SDK, follow this algorithm:

1. **Identify the Conflict:** Analyze the error log to find the specific version mismatch (e.g., `analyzer` requires `meta ^1.18.0`, but Flutter SDK pins `meta 1.17.0`).
2. **Isolate Constraints:**
    - Remove the conflicting package (e.g., `analyzer`) from `pubspec.yaml`.
    - Temporarily add the version of the pinned package (e.g., `meta: 1.17.0`) that causes the conflict to `pubspec.yaml`.
3. **Automated Discovery:**
    - Run `fvm dart pub get` to ensure the temporary environment is stable.
    - Run `fvm dart pub add <package_name>` (e.g., `fvm dart pub add analyzer`). This forces the Dart pub resolver to find the highest possible version of the package that is compatible with the current constraints.
4. **Capture & Revert:**
    - Note the version of the package that was successfully added.
    - Remove the temporary pinned package from `pubspec.yaml`.
    - Add the package back with the discovered compatible version (e.g., `analyzer: ^10.0.1`).
5. **Verify:**
    - Run `fvm dart pub get`.
    - Run `fvm dart analyze` to ensure no breaking changes or further conflicts were introduced.

- Confirm which package or packages are affected.
- Update code only in the package that owns the behavior.
- If changing public annotations or generator behavior, update affected README examples in both `README.md` and `README.ru.md`.
