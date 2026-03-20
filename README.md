# Knife

Набор пакетов для compile-time dependency injection на Dart.

В репозитории есть три основные части:

- `knife_annotations` - аннотации для описания DI-графа
- `knife_generator` - генератор кода для компонентов и модулей
- `example` - пример использования

## Содержание

- [Требования](#требования)
- [Как устроена библиотека](#как-устроена-библиотека)
- [Как подключить](#как-подключить)
- [Как запустить генератор](#как-запустить-генератор)
- [Аннотации](#аннотации)
- [Best Practices](#best-practices)
- [Ограничения](#ограничения)
- [Структура репозитория](#структура-репозитория)

## Требования

- **Dart**: >= 3.0.0
- **build_runner**: >= 2.4.0

Проверить версию Dart:

```bash
dart --version
```

## Что входит в пакет

`knife_annotations` экспортирует аннотации для описания DI-графа:

- `@inject`
- `@module`
- `@provides`
- `@binds`
- `@Component`

Все аннотации объявлены в [`knife_annotations/lib/knife_annotations.dart`](./knife_annotations/lib/knife_annotations.dart).

## Как устроена библиотека

Библиотека описывает DI-граф через два основных понятия: компоненты и модули.

Компонент - это корневая точка входа в граф зависимостей. Он перечисляет модули, которые участвуют в сборке, и объявляет методы, через которые можно получить готовые зависимости.

Модуль - это описание правил, по которым зависимости попадают в граф. В модуле можно:

- создать зависимость вручную через `@provides`
- связать абстракцию с реализацией через `@binds`

Если зависимость не создаётся методом модуля, она может быть построена через конструктор, помеченный `@inject`.

### Визуальная архитектура

```
┌─────────────────────────────────────────────┐
│  @Component (AppComponent)                  │
│  ├─ точка входа                             │
│  └─ выраженные методы доступа               │
└──────────────┬──────────────────────────────┘
               │ использует
               ▼
┌──────────────────────────────────────────────┐
│  @module (ServiceModule, NetworkModule)     │
│  ├─ @binds  (интерфейс -> реализация)       │
│  └─ @provides (конфигурация зависимостей)   │
└──────────────┬───────────────────────────────┘
               │ создаёт
               ▼
┌──────────────────────────────────────────────┐
│  Классы с @inject (ApiClient, Repository)   │
│  └─ конструкторы, помеченные @inject        │
└──────────────────────────────────────────────┘
```

**Поток работы:**

1. Вы помечаете классы аннотациями
2. `build_runner` запускает `knife_generator`
3. Генератор создаёт `*.component.dart` и `*.module.dart` файлы
4. Вы используете `KnifeAppComponent` как точку входа в граф

Концептуально это выглядит так:

```text
@Component
  -> подключает @module
  -> модуль содержит @provides и/или @binds
  -> конкретные классы создаются через @inject
```

То есть:

- `@Component` определяет, что доступно снаружи
- `@module` определяет, как собрать зависимости
- `@provides` вручную создаёт объект
- `@binds` связывает интерфейс с реализацией
- `@inject` помечает конструктор, который можно использовать для создания класса

## Как подключить

Подключите аннотации в `dependencies`, а генератор и `build_runner` в `dev_dependencies`.

```yaml
dependencies:
  knife_annotations: ^1.0.0

dev_dependencies:
  knife_generator: ^1.0.0
  build_runner: ^2.4.9
```

Импорт аннотаций:

```dart
import 'package:knife_annotations/knife_annotations.dart';
```

## Как запустить генератор

Установить зависимости:

```bash
dart pub get
```

Запустить генерацию:

```bash
dart run build_runner build
```

Если нужно пересобрать файлы с перезаписью конфликтующих outputs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

В результате генератор создаёт:

- `*.component.dart` для компонентов
- `*.module.dart` для модулей с `@binds`

## Best Practices

### Организация модулей

1. **Один модуль на фичу** — разделяйте модули по доменам:

   ```dart
   NetworkModule       // всё про API
   RepositoryModule    // хранилище данных
   ServiceModule       // бизнес-логика
   ```

2. **Используйте `@binds` для интерфейсов** — это явнее и безопаснее:

   ```dart
   @binds
   AuthService bindAuthService(AuthServiceImpl impl);
   ```

3. **Используйте `@provides` для конфигурации** — когда нужна логика создания:

   ```dart
   @provides
   ApiClient provideApiClient() {
     return ApiClient(baseUrl: env.apiUrl);
   }
   ```

4. **Избегайте циклических зависимостей** — рефакторьте модули, вводите промежуточные слои

5. **Тестирование** — создавайте отдельные тестовые модули вместо мокирования:

   ```dart
   @module
   abstract interface class MockServiceModule {
     @binds
     AuthService bindAuthService(MockAuthService impl);
     factory MockServiceModule() = KnifeMockServiceModule;
   }
   ```

6. **Именование** — используйте префиксы для ясности:
   - `provide*` для методов `@provides`
   - `bind*` для методов `@binds`

## Ограничения

### Что не поддерживается

- **Циклические зависимости** — генератор выдаст ошибку. Решение: введите промежуточный класс
- **Generic методы в провайдерах** — используйте конкретные типы:

  ```dart
  // ✗ Не работает
  @provides
  T provide<T>() => ...;

  // ✓ Работает
  @provides
  UserRepository provideUserRepository() => ...;

  // ✗ Не работает
  @provides
  T provide<T>() => ...;

  // ✓ Работает
  @provides
  UserRepository provideUserRepository() => ...;
  ```

- **Анонимные функции** как зависимости — используйте классы
- **Optional/nullable зависимости** — все зависимости обязательны
- **Lazy initialization** — все зависимости создаются сразу при инициализации компонента

### Как работает генерация

- Анализ происходит в **compile-time**, ошибки видны сразу
- Сгенерированный код **полностью типизирован** (type-safe)

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

Параметры:

- `modules` - список модулей, подключённых к компоненту

Требования:

- класс должен быть абстрактным
- должен быть factory-конструктор вида `factory AppComponent() = KnifeAppComponent;`
- должен быть импорт сгенерированного файла вида `import 'app_component.component.dart';`

### `@module`

Помечает модуль, который описывает способы получения зависимостей.

У модуля есть три допустимых формы.

#### Вариант 1. Неабстрактный модуль только с `@provides`

Используется, когда все зависимости модуль создаёт вручную, а `@binds`-методов в нём нет.

Требования:

- модуль должен быть обычным неабстрактным классом

Пример:

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

Требования:

- модуль можно объявить как `abstract interface class` или как `abstract class`
- модуль должен содержать только `@binds`-методы
- в файле модуля должен быть `part 'module_file_name.module.dart';`
- модуль должен иметь factory-конструктор вида `factory AppModuleInterface() = KnifeAppModuleInterface;`

Пример:

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

Требования:

- модуль должен быть `abstract class`
- в файле модуля должен быть `part 'module_file_name.module.dart';`
- модуль должен иметь factory-конструктор вида `factory AppModule() = KnifeAppModule;`
- модуль должен иметь private non-factory constructor вида `AppModule._();`

Пример:

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

Подходит для случаев, когда:

- объект нужно собрать вручную
- зависимость приходит из сторонней библиотеки
- нужен контроль над параметрами конструктора

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

Обычно используется для маппинга интерфейса на конкретный класс:

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

Идея `@binds` в том, что реализация уже существует, а модуль только объявляет связь:

```text
AuthService -> AuthServiceImpl
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

Конструктор с `@inject` может принимать зависимости в параметрах:

```dart
import 'package:knife_annotations/knife_annotations.dart';

class UserRepository {
  @inject
  UserRepository(this.apiClient);

  final ApiClient apiClient;
}
```

Можно использовать и именованный конструктор:

```dart
class Logger {
  const Logger._();

  @inject
  const Logger.console();
}
```

## Пример целиком

```dart
import 'package:knife_annotations/knife_annotations.dart';
import 'app_component.component.dart';

part 'app_module.module.dart';

abstract class ApiService {
  String load();
}

class ApiServiceImpl implements ApiService {
  @inject
  ApiServiceImpl();

  @override
  String load() => 'ok';
}

@module
abstract interface class AppModule {
  @binds
  ApiService bindApiService(ApiServiceImpl impl);

  factory AppModule() = KnifeAppModule;
}

@Component(
  modules: [AppModule],
)
abstract class AppComponent {
  ApiService apiService();

  factory AppComponent() = KnifeAppComponent;
}
```

В этом примере:

- `ApiServiceImpl` может быть создан через `@inject`
- `AppModule` связывает `ApiService` с `ApiServiceImpl`
- `AppModule` оформлен как модуль только с `@binds`
- в файле модуля подключён `part 'app_module.module.dart';`
- `AppComponent` объявляет корневую зависимость `apiService()` и подключает сгенерированную реализацию через `factory`

## Структура репозитория

- [`knife_annotations`](./knife_annotations) - пакет с аннотациями
- [`knife_generator`](./knife_generator) - пакет с кодогенератором
- [`example`](./example) - пример использования

## License

Проект распространяется под лицензией Apache License 2.0.

Copyright 2026 Roman Mulliaminov

Полный текст лицензии: [LICENSE](./LICENSE).

`knife_annotations` содержит только аннотации. Логика анализа графа зависимостей, генерация кода и runtime-поведение находятся в `knife_generator`.
