Read [AI_RULES.md](../AI_RULES.md) first.

- `AI_RULES.md` is the canonical source of truth.
- Use package-local commands only. Do not invent repo-root workflows.
- Do not edit or commit generated `*.component.dart` or `*.module.dart`.
- Keep annotations in `knife_annotations/lib/knife_annotations.dart`.
- Keep generator lookup compatible with `package:knife_annotations/knife_annotations.dart`.
- Preserve generated filenames `.component.dart` and `.module.dart`.
- Preserve generated class naming `Knife{TypeName}`.
