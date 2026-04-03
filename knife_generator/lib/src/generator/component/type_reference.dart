import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

Reference referType(DartType type) {
  ensureSupportedType(type);

  final element = type.element;
  if (element == null) {
    throw InvalidGenerationSourceError(
        'Type ${type.getDisplayString()} is not supported.');
  }

  return refer(element.displayName, element.library?.identifier);
}

String typeIdentifier(DartType type) {
  ensureSupportedType(type);

  final element = type.element;
  if (element == null) {
    throw InvalidGenerationSourceError(
        'Type ${type.getDisplayString()} is not supported.');
  }

  return element.displayName;
}

void ensureSupportedType(DartType type) {
  if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
    throw InvalidGenerationSourceError(
      'Parameterized types are not supported: ${type.getDisplayString()}.',
    );
  }
}
