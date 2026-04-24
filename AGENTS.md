# Agent execution rules

## Execution style

- Never execute more than one planned step per response.
- Before making changes, restate the current goal in 1-2 lines.
- After every tool call sequence, emit a compact progress block.

## Required progress block

Always end implementation messages with:

STATUS:

- current_step:
- completed:
- files_changed:
- next_step:
- blockers:

## File discipline

- Prefer modifying at most 1-3 files per step.
- If the task expands, stop and rewrite the remaining plan.

## Memory discipline

- Treat the latest STATUS block as source of truth.
- When context is uncertain, summarize current state before continuing.

See [AI_RULES.md](./AI_RULES.md) for the canonical rules.

## Core Rules

- `AI_RULES.md` is the single source of truth. Do not duplicate or override it here.
- Run commands from the package directory they belong to. Do not invent repo-root workflows.
- Do not hand-edit or commit generated `*.component.dart` or `*.module.dart` files.
- Keep `knife_annotations` as the annotation API package.
- Keep `knife_generator` as the generator implementation package.
- Keep `knife_generator/example` as the sample consumer app.

## Commands

- `knife_annotations`: `dart pub get`, `dart analyze`
- `knife_generator`: `dart pub get`, `dart analyze`, `dart test`
- `knife_generator/example`: `flutter pub get`, `flutter analyze`, `dart run build_runner build`, `dart run build_runner build --delete-conflicting-outputs`

## Generator Invariants

- Keep annotations in `knife_annotations/lib/knife_annotations.dart`.
- Keep generator lookup compatible with `package:knife_annotations/knife_annotations.dart`.
- Preserve generated filenames: `.component.dart` and `.module.dart`.
- Preserve generated class naming: `Knife{TypeName}`.
- Use `InvalidGenerationSourceError` for generator validation failures.
