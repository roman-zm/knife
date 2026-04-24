# Changelog

## 1.0.3

- Enhancement dependency injection with external dependencies support.

## 1.0.2

- Added support for `@cached` providers for constructor, `@provides`, and `@binds` dependency resolution paths.
- Refactored component generation into dedicated stages (`ComponentSpec`, provider methods, factory methods, module fields, and type references).
- Improved dependency graph traversal/provider reuse and updated generator tests and example usage.

## 1.0.1

- Refactored component generation and dependency graph building to improve generated output and module handling.
- Renamed internal builders and fixed the builder factory name in `build.yaml`.
- Moved the example app into `knife_generator/example` and expanded it with navigation plus additional component/module examples.
- Refreshed README documentation, added Russian docs, and enabled stricter analyzer settings.

## 1.0.0

- First public release of the Knife code generator.
