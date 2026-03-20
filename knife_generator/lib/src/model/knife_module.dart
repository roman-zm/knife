import 'package:analyzer/dart/element/element.dart';

class KnifeModule {
  const KnifeModule({
    required this.name,
    required this.element,
  });

  final String name;
  final ClassElement element;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnifeModule && name == other.name && element == other.element;

  @override
  int get hashCode => Object.hash(
        name,
        element,
      );

  @override
  String toString() => 'KnifeModule(name: $name)';

  Iterable<String> get imports => element.methods
      .expand(
        (method) => [
          ...method.formalParameters.map((p) => p.type.element),
          method.returnType.element,
        ],
      )
      .whereType<ClassElement>()
      .map((e) => e.library.identifier)
      .toSet();
}
