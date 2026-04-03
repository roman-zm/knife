# AI Rules

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
- There is no workspace manager config such as `melos.yaml`.
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

### Notes

- No dedicated repo-level install/build/test command is documented.
- No documented repo-specific run/dev command is defined. Do not invent one.

## Architecture Rules

- Keep annotation declarations in `knife_annotations/lib/knife_annotations.dart`.
- Keep generator annotation lookup compatible with `package:knife_annotations/knife_annotations.dart`.
- Keep the public builder entrypoints in:
  - `knife_generator/lib/component_library_builder.dart`
  - `knife_generator/lib/module_part_builder.dart`
- Keep component generation producing `.component.dart` files.
- Keep module generation producing `.module.dart` files.
- Keep generated class naming as `Knife{TypeName}`.
- Keep generator validation failures using `InvalidGenerationSourceError`.
- Keep `knife_generator/lib/src/` as internal implementation, not public package API.
- Preserve the split between annotations package and generator package.

## Coding Conventions

- Match the existing package structure. Do not collapse packages together.
- In public library code, keep public API documentation where the current analysis rules require it.
- In `knife_generator/lib/src/**`, `public_member_api_docs` is intentionally disabled; do not add docs-only churn there.
- Use `formatCode(...)` for generator-produced Dart code formatting.
- Do not move generator internals out of the current `lib/src/generator/**`, `lib/src/model/**`, and `lib/src/utils/**` layout without updating all affected imports.
- When behavior changes, keep English and Russian README examples aligned with the code.

## Forbidden Patterns

- Do not hand-edit generated `*.component.dart` or `*.module.dart` files.
- Do not commit generated `*.component.dart` or `*.module.dart` files.
- Do not invent repo-root task commands or a workspace tool that does not exist here.
- Do not move, duplicate, or rename the annotation library without updating generator lookup logic.
- Do not change generated file extensions or `Knife{TypeName}` naming unless intentionally changing the generator contract everywhere.

## Generated Code

- Generated files are source outputs produced by `build_runner`.
- Repo root `.gitignore` ignores `**/*.component.dart` and `**/*.module.dart`.
- Example source files import or reference generated outputs by exact name. Keep those names stable:
  - `import 'app_component.component.dart';`
  - `part 'app_module.module.dart';`
- If generator behavior changes, regenerate outputs in the consuming package locally, but keep generated files untracked.

## Monorepo Rules

- Treat each directory with its own `pubspec.yaml` as an independent package.
- Scope commands, fixes, and validation to the affected package.
- Do not assume shared root dependencies or a root `pubspec.yaml`.
- Do not add `pubspec.lock` for `knife_annotations` or `knife_generator`; root `.gitignore` ignores them.
- Keep `knife_generator/example/pubspec.lock` tracked unless there is an explicit reason to change it.

## Completion Checklist

- Confirm which package or packages are affected.
- Update code only in the package that owns the behavior.
- If changing public annotations or generator behavior, update affected README examples in both `README.md` and `README.ru.md`.
- If changing generator output contract, regenerate example outputs locally before finishing.
- Run analyze and test commands only for the affected package scope.
- Check that no generated files are staged for commit.

## Review Checklist

- Annotation API and generator behavior still match.
- `build.yaml` still matches generated file extensions and builder entrypoints.
- Example imports and `part` directives still match generated filenames.
- No generated outputs were committed.
- No ignored lockfiles were added for `knife_annotations` or `knife_generator`.
- Package-local commands listed in docs and instructions still match the repo.

## Repo-Specific Notes

- Root `.fvmrc` and `knife_generator/example/.fvmrc` pin Flutter `3.32.0`.
- `knife_generator/example/pubspec_overrides.yaml` exists locally and points the example at sibling packages.
- `knife_generator/example/pubspec_overrides.yaml` is not tracked by Git, so do not rely on it as committed repo state.
- For pre-release work, follow `release.md`.
