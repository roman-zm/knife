# Pre-release

## Scope

- This checklist applies to the publishable packages:
  - `knife_annotations`
  - `knife_generator`
- `knife_generator/example` is not publishable because `publish_to: "none"` is set in its `pubspec.yaml`.

## Steps

1. **Determine Version and Changes (NEW)**
   - Use Git history to identify all changes since the last release tag.
   - Calculate the previous version number based on Git history (e.g., using `git describe --tags`).
   - Decide on the next semantic version (MAJOR, MINOR, or PATCH) based on the scope of changes found in step 1.

2. Prepare changelogs.
   - Add a new top entry to:
     - `knife_annotations/CHANGELOG.md`
     - `knife_generator/CHANGELOG.md`
   - Summarize user-visible changes only.
   - Keep entries aligned with the actual code and docs changes included in the release.

3. Update README files and keep them aligned.
   - Update both root docs:
     - `README.md`
     - `README.ru.md`
   - Update package docs:
     - `knife_annotations/README.md`
     - `knife_annotations/README.ru.md`
     - `knife_generator/README.md`
     - `knife_generator/README.ru.md`
   - Reflect only relevant user-facing documentation changes from the changelog in the README files. Do not copy the changelog verbatim into README files. Only update README sections affected by the release.
   - If version snippets are shown in install examples, update them consistently.

4. Bump package versions in `pubspec.yaml`.
   - Update `knife_annotations/pubspec.yaml`
   - Update `knife_generator/pubspec.yaml`
   - Keep `knife_generator` dependency on `knife_annotations` in sync with the new published version range.

5. Run package validation before publish.
   - In `knife_annotations`:
     - `dart pub get`
     - `dart analyze`
   - In `knife_generator`:
     - `dart pub get`
     - `dart analyze`
     - `dart test`
   - In `knife_generator/example`:
     - `flutter pub get`
     - `flutter analyze`

6. Run publish dry-runs for each publishable package.
   - In `knife_annotations`:
     - `dart pub publish --dry-run`
   - In `knife_generator`:
     - `dart pub publish --dry-run`
   - Review warnings and fix package contents before real publish.

## What Else Is Needed

- Keep README package version examples in sync with the new release versions.
- Keep `knife_generator/pubspec.yaml` dependency on `knife_annotations` in sync with the annotation package release.
- Verify changelog entries are present before running `dart pub publish --dry-run`, because pub.dev expects release notes files to exist.
- If generator output names or usage changed, verify example imports and `part` directives still match generated filenames.
- Make sure no generated `*.component.dart` or `*.module.dart` files are staged.
- Do not rely on `knife_generator/example/pubspec_overrides.yaml` as committed repo state; it exists locally but is not tracked.

## Done Criteria

- README files are updated and mutually consistent.
- Both package versions are bumped.
- `knife_generator` dependency on `knife_annotations` is updated if needed.
- Both changelog files have a new release entry.
- Analyze and test checks pass in affected packages.
- `dart pub publish --dry-run` is clean for both publishable packages.
