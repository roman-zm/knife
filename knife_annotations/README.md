# knife_annotations

[Russian version](./README.ru.md)

Annotations for Knife, a compile-time dependency injection library for Dart.

This package only contains annotation declarations and is added to `dependencies`. Code generation requires the separate package [`knife_generator`](https://pub.dev/packages/knife_generator), which should be added to `dev_dependencies`.

## Installation

```yaml
dependencies:
  knife_annotations: ^1.0.2

dev_dependencies:
  knife_generator: ^1.0.2
  build_runner: ^2.4.9
```

Import:

```dart
import 'package:knife_annotations/knife_annotations.dart';
```

## Annotations

### `@Component`

Marks the root component that combines modules and declares entry points into the dependency graph.

```dart
import 'package:knife_annotations/knife_annotations.dart';
import 'app_component.component.dart';

@Component(
  modules: [NetworkModule, ServiceModule],
)
abstract class AppComponent {
  AuthService authService();
  UserRepository userRepository();

  factory AppComponent() = KnifeAppComponent;
}
```

Requirements:

- the class must be abstract
- it must have a factory constructor in the form `factory AppComponent() = KnifeAppComponent;`
- it must import the generated file, for example `import 'app_component.component.dart';`

### `@module`

Marks a module that describes how dependencies are obtained.

A module has three valid forms.

#### Option 1. Non-abstract module with only `@provides`

Used when the module creates all dependencies manually and does not contain any `@binds` methods.

```dart
import 'package:knife_annotations/knife_annotations.dart';

@module
class NetworkModule {
  @provides
  ApiClient provideApiClient() => ApiClient();
}
```

#### Option 2. Fully abstract module with only `@binds`

Used when the module only binds abstractions to implementations.

```dart
import 'package:knife_annotations/knife_annotations.dart';

part 'service_module.module.dart';

@module
abstract interface class ServiceModule {
  @binds
  AuthService bindAuthService(AuthServiceImpl impl);

  factory ServiceModule() = KnifeServiceModule;
}
```

#### Option 3. Abstract module with mixed `@provides` and `@binds`

Used when some dependencies are created manually and others are declared as bindings.

```dart
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module.module.dart';

@module
abstract class AppModule {
  AppModule._();

  @provides
  ApiClient provideApiClient() => ApiClient();

  @binds
  AuthService bindAuthService(AuthServiceImpl impl);

  factory AppModule() = KnifeAppModule;
}
```

### `@provides`

Marks a module method that manually creates or configures a dependency.

```dart
import 'package:knife_annotations/knife_annotations.dart';

@module
class RepositoryModule {
  @provides
  UserRepository provideUserRepository(ApiClient apiClient) {
    return UserRepository(apiClient);
  }
}
```

### `@binds`

Marks an abstract module method that binds an abstraction to an implementation.

```dart
import 'package:knife_annotations/knife_annotations.dart';

part 'service_module.module.dart';

@module
abstract interface class ServiceModule {
  @binds
  AuthService bindAuthService(AuthServiceImpl impl);

  factory ServiceModule() = KnifeServiceModule;
}
```

### `@cached`

Marks a dependency provider as cached inside the generated component.
Can be used on `@provides`, `@binds`, and `@inject` declarations.

```dart
import 'package:knife_annotations/knife_annotations.dart';

class ApiClient {
  @inject
  @cached
  ApiClient();
}
```

### `@inject`

Marks a constructor that the DI generator should use to create an instance.

```dart
import 'package:knife_annotations/knife_annotations.dart';

class ApiClient {
  @inject
  ApiClient();
}
```

```dart
import 'package:knife_annotations/knife_annotations.dart';

class UserRepository {
  @inject
  UserRepository(this.apiClient);

  final ApiClient apiClient;
}
```

## How to run generation

```bash
dart run build_runner build
```

If you need to rebuild files and overwrite conflicting outputs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Limitations

- Cyclic dependencies are not supported
- Generic methods in providers are not supported
- All dependencies are required; optional/nullable scenarios are not supported
