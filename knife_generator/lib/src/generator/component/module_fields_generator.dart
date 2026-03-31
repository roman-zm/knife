import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

Iterable<Field> getModuleFields(List<ClassElement> modules) {
  return modules.map(_getModuleField);
}

Field _getModuleField(ClassElement module) {
  final constructor = _chooseConstructor(module);

  final assignment = refer(
    constructor.displayName,
    module.library.identifier,
  ).call([]);

  return Field(
    (b) => b
      ..name = '_${module.name}'
      ..modifier = FieldModifier.final$
      ..assignment = assignment.code,
  );
}

ConstructorElement _chooseConstructor(ClassElement element) {
  final constructors = element.constructors;

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
