# knife_generator

[Russian version](./README.ru.md)

Code generator for Knife, a compile-time dependency injection library for Dart.

This package is added to `dev_dependencies` and used together with `build_runner`. The annotations are defined in a separate package, [`knife_annotations`](https://pub.dev/packages/knife_annotations).

## Installation

```yaml
dependencies:
  knife_annotations: ^1.0.3

dev_dependencies:
  knife_generator: ^1.0.3
  build_runner: ^2.4.9
```

## How the library works

Knife describes a DI graph through two main concepts: components and modules.

A component is the root entry point into the dependency graph. It lists the modules involved in assembly and declares the methods through which ready-to-use dependencies can be obtained.

A module describes the rules by which dependencies are added to the graph. Inside a module you can:

- create a dependency manually via `@provides`
- bind an abstraction to an implementation via `@binds`

If a dependency is not created by a module method, it can be built through a constructor marked with `@inject`.
Dependencies marked with `@cached` are created once and reused within the generated component.

### External Dependencies

Starting from version 1.0.3, Knife supports external package dependencies. You can import and inject dependencies from external packages directly in your component:

```dart
import 'package:example/repository/screen/screen_repository.dart';
import 'package:example/services/screen/screen_service.dart';

@Component(modules: [ScreenModule])
abstract class ScreenComponent {
  ScreenService screenService();
  ScreenRepository screenRepository();

  @inject
  factory ScreenComponent(ScreenService screenService) = KnifeScreenComponent;
}
```

## How to run the generator

Install dependencies:

```bash
dart pub get
```

Run generation:

```bash
dart run build_runner build
```

If you need to rebuild files and overwrite conflicting outputs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

As a result, the generator creates:

- `*.component.dart` for components
- `*.module.dart` for modules with `@binds`

## Generator capabilities

- analyzes annotations from `knife_annotations`
- builds the dependency graph during generation
- generates type-safe `component` and `module` implementations
- supports dependency caching for providers marked with `@cached`
- validates module and component structure before code is emitted
- reports graph build errors at compile time

## Limitations

- Cyclic dependencies are not supported
- Generic methods in providers are not supported
- Lazy initialization is not supported
