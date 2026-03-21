# Knife

[Russian version](./README.ru.md)

A set of packages for compile-time dependency injection in Dart.

The repository contains three main parts:

- `knife_annotations` - annotations for describing the DI graph
- `knife_generator` - code generator for components and modules
- `example` - usage example

## Contents

- [Requirements](#requirements)
- [How the library works](#how-the-library-works)
- [How to add it](#how-to-add-it)
- [How to run the generator](#how-to-run-the-generator)
- [Annotations](#annotations)
- [Best Practices](#best-practices)
- [Limitations](#limitations)

## Requirements

- **Dart**: >= 3.0.0
- **build_runner**: >= 2.4.0

Check your Dart version:

```bash
dart --version
```

## What the package includes

`knife_annotations` exports annotations for describing the DI graph:

- `@inject`
- `@module`
- `@provides`
- `@binds`
- `@Component`

All annotations are declared in [`knife_annotations/lib/knife_annotations.dart`](./knife_annotations/lib/knife_annotations.dart).

## How the library works

The library describes a DI graph through two main concepts: components and modules.

A component is the root entry point into the dependency graph. It lists the modules involved in assembly and declares the methods through which ready-to-use dependencies can be obtained.

A module describes the rules by which dependencies are added to the graph. Inside a module you can:

- create a dependency manually via `@provides`
- bind an abstraction to an implementation via `@binds`

If a dependency is not created by a module method, it can be built through a constructor marked with `@inject`.

### Visual architecture

```text
┌─────────────────────────────────────────────┐
│  @Component (AppComponent)                  │
│  ├─ entry point                             │
│  └─ explicit access methods                 │
└──────────────┬──────────────────────────────┘
               │ uses
               ▼
┌──────────────────────────────────────────────┐
│  @module (ServiceModule, NetworkModule)     │
│  ├─ @binds  (interface -> implementation)   │
│  └─ @provides (dependency configuration)    │
└──────────────┬───────────────────────────────┘
               │ creates
               ▼
┌──────────────────────────────────────────────┐
│  Classes with @inject (ApiClient, Repo)     │
│  └─ constructors marked with @inject        │
└──────────────────────────────────────────────┘
```

**Workflow:**

1. You mark classes with annotations
2. `build_runner` starts `knife_generator`
3. The generator creates `*.component.dart` and `*.module.dart` files
4. You use `KnifeAppComponent` as the graph entry point

Conceptually, it looks like this:

```text
@Component
  -> connects @module
  -> module contains @provides and/or @binds
  -> concrete classes are created via @inject
```

In other words:

- `@Component` defines what is available from the outside
- `@module` defines how dependencies are assembled
- `@provides` manually creates an object
- `@binds` connects an interface to an implementation
- `@inject` marks a constructor that can be used to create a class

## How to add it

Add annotations to `dependencies`, and the generator with `build_runner` to `dev_dependencies`.

```yaml
dependencies:
  knife_annotations: ^1.0.0

dev_dependencies:
  knife_generator: ^1.0.0
  build_runner: ^2.4.9
```

Import the annotations:

```dart
import 'package:knife_annotations/knife_annotations.dart';
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

## Best Practices

### Module organization

1. **One module per feature**: split modules by domain:

   ```dart
   NetworkModule       // everything API-related
   RepositoryModule    // data storage
   ServiceModule       // business logic
   ```

2. **Use `@binds` for interfaces**: this is more explicit and safer:

   ```dart
   @binds
   AuthService bindAuthService(AuthServiceImpl impl);
   ```

3. **Use `@provides` for configuration**: when creation logic is needed:

   ```dart
   @provides
   ApiClient provideApiClient() {
     return ApiClient(baseUrl: env.apiUrl);
   }
   ```

4. **Avoid cyclic dependencies**: refactor modules and introduce intermediate layers

5. **Testing**: create dedicated test modules instead of mocking:

   ```dart
   @module
   abstract interface class MockServiceModule {
     @binds
     AuthService bindAuthService(MockAuthService impl);
     factory MockServiceModule() = KnifeMockServiceModule;
   }
   ```

6. **Naming**: use prefixes for clarity:
   - `provide*` for `@provides` methods
   - `bind*` for `@binds` methods

## Limitations

### What is not supported

- **Cyclic dependencies**: the generator will throw an error. Solution: introduce an intermediate class
- **Generic methods in providers**: use concrete types:

  ```dart
  // ✗ Does not work
  @provides
  T provide<T>() => ...;

  // ✓ Works
  @provides
  UserRepository provideUserRepository() => ...;
  ```

- **Anonymous functions** as dependencies: use classes instead
- **Optional/nullable dependencies**: all dependencies are required
