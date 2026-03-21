# knife_annotations

[English version](./README.md)

Аннотации для Knife, библиотеки compile-time dependency injection на Dart.

Пакет содержит только декларации аннотаций и подключается в `dependencies`. Для генерации кода нужен отдельный пакет [`knife_generator`](https://pub.dev/packages/knife_generator), который подключается в `dev_dependencies`.

## Установка

```yaml
dependencies:
  knife_annotations: ^1.0.0

dev_dependencies:
  knife_generator: ^1.0.0
  build_runner: ^2.4.9
```

Импорт:

```dart
import 'package:knife_annotations/knife_annotations.dart';
```

## Аннотации

### `@Component`

Помечает корневой компонент, который объединяет модули и объявляет точки входа в граф зависимостей.

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

Требования:

- класс должен быть абстрактным
- должен быть factory-конструктор вида `factory AppComponent() = KnifeAppComponent;`
- должен быть импорт сгенерированного файла вида `import 'app_component.component.dart';`

### `@module`

Помечает модуль, который описывает способы получения зависимостей.

У модуля есть три допустимых формы.

#### Вариант 1. Неабстрактный модуль только с `@provides`

Используется, когда все зависимости модуль создаёт вручную, а `@binds`-методов в нём нет.

```dart
import 'package:knife_annotations/knife_annotations.dart';

@module
class NetworkModule {
  @provides
  ApiClient provideApiClient() => ApiClient();
}
```

#### Вариант 2. Полностью абстрактный модуль только с `@binds`

Используется, когда модуль только связывает абстракции с реализациями.

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

#### Вариант 3. Абстрактный модуль со смешанными `@provides` и `@binds`

Используется, когда часть зависимостей создаётся вручную, а часть описывается как биндинги.

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

Помечает метод модуля, который вручную создаёт или конфигурирует зависимость.

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

Помечает абстрактный метод модуля, который связывает абстракцию с реализацией.

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

### `@inject`

Помечает конструктор, который DI-генератор должен использовать для создания экземпляра.

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

## Как запустить генерацию

```bash
dart run build_runner build
```

Если нужно пересобрать файлы с перезаписью конфликтующих outputs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Ограничения

- Циклические зависимости не поддерживаются
- Generic-методы в провайдерах не поддерживаются
- Все зависимости обязательны, optional/nullable сценарии не поддерживаются
