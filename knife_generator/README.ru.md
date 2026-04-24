# knife_generator

[English version](./README.md)

Генератор кода для Knife, библиотеки compile-time dependency injection на Dart.

Этот пакет подключается в `dev_dependencies` и используется вместе с `build_runner`. Аннотации лежат в отдельном пакете [`knife_annotations`](https://pub.dev/packages/knife_annotations).

## Установка

```yaml
dependencies:
  knife_annotations: ^1.0.3

dev_dependencies:
  knife_generator: ^1.0.3
  build_runner: ^2.4.9
```

## Как устроена библиотека

Knife описывает DI-граф через два основных понятия: компоненты и модули.

Компонент это корневая точка входа в граф зависимостей. Он перечисляет модули, которые участвуют в сборке, и объявляет методы, через которые можно получить готовые зависимости.

Модуль это описание правил, по которым зависимости попадают в граф. В модуле можно:

- создать зависимость вручную через `@provides`
- связать абстракцию с реализацией через `@binds`

Если зависимость не создаётся методом модуля, она может быть построена через конструктор, помеченный `@inject`.
Зависимости, помеченные `@cached`, создаются один раз и переиспользуются внутри сгенерированного компонента.

## Внешние зависимости

С версии 1.0.3 Knife поддерживает внешние зависимости из сторонних пакетов. Вы можете внедрять зависимости из других пакетов через модуль компонента.

Пример использования внешней зависимости:

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

## Возможности генератора

- анализирует аннотации из `knife_annotations`
- строит граф зависимостей во время генерации
- генерирует типобезопасные `component` и `module` реализации
- поддерживает кеширование зависимостей для провайдеров, помеченных `@cached`
- валидирует структуру модулей и компонентов до генерации кода
- показывает ошибки сборки графа на этапе compile-time

## Ограничения

- Циклические зависимости не поддерживаются
- Generic-методы в провайдерах не поддерживаются
- Lazy initialization не поддерживается
