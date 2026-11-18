import 'package:analyzer/dart/element/element.dart';

extension ElementExt on Element {
  static const _knifeAnnotationsLibrary =
      'package:knife_annotations/knife_annotations.dart';

  bool hasAnnotationOfType(Type type) {
    final expectedName = type.toString();
    return metadata.annotations.any((annotation) {
      final value = annotation.computeConstantValue();
      final annotationType = value?.type?.element;

      return annotationType?.name == expectedName &&
          annotationType?.library?.identifier == _knifeAnnotationsLibrary;
    });
  }
}

extension ConstructorElementExt on ConstructorElement {
  /// Reference name suitable for `code_builder` constructor invocations.
  ///
  /// Analyzer 14+ reports unnamed constructors as `Class.new`; emit `Class`
  /// instead so generated code stays free of unnecessary `.new`.
  String get invocationName {
    final constructorName = name;
    final className = enclosingElement.name;
    if (className == null) {
      return displayName;
    }
    if (constructorName == null || constructorName.isEmpty || constructorName == 'new') {
      return className;
    }
    return '$className.$constructorName';
  }
}
