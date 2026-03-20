import 'package:analyzer/dart/element/element.dart';

extension ElementExt on Element {
  bool hasAnnotationOfType(Type type) {
    final expectedName = type.toString();
    return metadata.annotations.any((annotation) {
      final value = annotation.computeConstantValue();
      final annotationType = value?.type?.element;
      return annotationType?.name == expectedName;
    });
  }
}
