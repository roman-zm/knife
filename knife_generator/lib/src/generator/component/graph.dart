import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:knife_generator/src/generator/component/knife_component.dart';
import 'package:knife_generator/src/model/knife_module.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/utils/inject.dart';
import 'package:source_gen/source_gen.dart';

/*
1. Получаем все типы которые возвращают геттеры в классе компонента
2. Получаем все модули из аннотации
3. Получаем все типы которые возвращают методы в модулях
4. Создаем граф зависимостей, где ключ - тип, а значение - список типов, от которых он зависит
5. Если тип из геттеров не найден в модулях, то убеждаемся, что:
    - он не является абстрактным классом
    - он имеет конструктор с аннотацией @Inject или, если он имеет только 
    конструктор по умолчанию, сам класс имеет аннотацию @Inject.
   В ином случае кидаем ошибку.
6. Типы от которых зависят типы из геттеров добавляем в граф зависимостей
7. Продолжаем до тех пор, пока не будут обработаны все типы 
*/

typedef DependencyGraph = Map<DartType, KnifeProvider>;

DependencyGraph buildGraph(KnifeComponent component) {
  final DependencyGraph graph = {};

  final typesStack = component.providedTypes;
  while (typesStack.isNotEmpty) {
    final currentType = typesStack.removeLast();

    final provider = component.getProviderForType(currentType);

    graph[currentType] = provider;
    typesStack.addAll(provider.dependencies);
  }

  return graph;
}

extension on KnifeComponent {
  KnifeProvider getProviderForType(DartType type) {
    final modules = this.modules;
    final moduleProviders = modules
        .map((module) => module.getProviderForType(type))
        .nonNulls
        .toList();

    // Должен быть не более одного провайдера, иначе это ошибка
    if (moduleProviders.length > 1) {
      throw InvalidGenerationSourceError(
        'Multiple providers found for type $type',
        element: element,
      );
    }

    if (moduleProviders.isNotEmpty) {
      return moduleProviders.first;
    }

    // Если провайдер не найден в модулях, то проверяем конструкторы класса
    final typeElement = type.element;
    if (typeElement is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Type $type is not a class.',
        element: element,
      );
    }

    return InjectKnifeProvider(
      type,
      findInjectAnnotatedConstructor(typeElement),
    );
  }
}

extension on KnifeModule {
  KnifeProvider? getProviderForType(DartType type) {
    final method =
        element.methods.firstWhereOrNull((method) => method.returnType == type);

    if (method != null) {
      return ModuleKnifeProvider(type, method);
    }

    return null;
  }
}
