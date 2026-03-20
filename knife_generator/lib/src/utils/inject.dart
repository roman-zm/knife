import 'package:analyzer/dart/element/element.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

ConstructorElement findInjectAnnotatedConstructor(
  ClassElement returnTypeElement,
) {
  final injectConstructors = returnTypeElement.constructors
      .where((constructor) => constructor.hasAnnotationOfType(Inject))
      .toList();

  if (injectConstructors.length == 1) {
    return injectConstructors.first;
  }

  throw InvalidGenerationSourceError(
    'Type ${returnTypeElement.displayString()} must have exactly one constructor annotated with @Inject.',
    element: returnTypeElement,
  );
}
