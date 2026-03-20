import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:knife_generator/src/model/knife_module.dart';
import 'package:source_gen/source_gen.dart';

Iterable<Field> getModuleFields(List<KnifeModule> modules) {
  return modules.map(_getModuleField);
}

Field _getModuleField(KnifeModule module) {
  final defaultConstructor = _chooseConstructor(module.element);
  final constructorNameValue = defaultConstructor.name;

  // Формируем код для создания экземпляра
  final constructorName =
      constructorNameValue == null || constructorNameValue == 'new'
          ? '${module.name}()'
          : '${module.name}.$constructorNameValue()';

  final assignment = Code(constructorName);

  return Field(
    (b) => b
      ..name = '_${module.name}'
      ..type = refer(module.name)
      ..modifier = FieldModifier.final$ // Поле должно быть final
      ..assignment = assignment,
  );
}

ConstructorElement _chooseConstructor(ClassElement element) {
  // Находим конструкторы элемента
  final constructors = element.constructors;

  // Ищем конструктор без аргументов
  final noArgConstructors = constructors.where(
    (constructor) => constructor.formalParameters.isEmpty,
  );

  final defaultConstructor = constructors.firstWhereOrNull(
    (constructor) => constructor.isDefaultConstructor,
  );
  final constructor = defaultConstructor ?? noArgConstructors.firstOrNull;

  if (constructor == null) {
    throw InvalidGenerationSourceError(
      'Class ${element.name} must have a constructor without arguments.',
      element: element,
    );
  }
  return constructor;
}
