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
