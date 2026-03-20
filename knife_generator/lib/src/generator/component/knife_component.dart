import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/method_wrapper.dart';
import 'package:knife_generator/src/model/knife_module.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

class KnifeComponent {
  KnifeComponent._(this.element, this.annotation);
  factory KnifeComponent(Element element, ConstantReader annotation) {
    if (element is! ClassElement || !element.isAbstract) {
      throw InvalidGenerationSourceError(
        '`@Component` can only be used on abstract classes.',
        element: element,
      );
    }
    return KnifeComponent._(element, annotation);
  }

  final ClassElement element;
  final ConstantReader annotation;

  String get generatedClassName => 'Knife${element.name}';

  List<MethodWrapper> get abstractMethods => element.methods
      .where((element) => element.isAbstract)
      .map((e) => MethodWrapper(e))
      .toList();

  List<DartType> get providedTypes =>
      abstractMethods.map((e) => e.element.returnType).toList();

  List<KnifeModule> get modules => _getModules(annotation);

  List<KnifeModule> _getModules(ConstantReader annotation) {
    final modulesReader = annotation.read('modules');
    final modules = modulesReader.listValue
        .map((module) => module.toTypeValue())
        .nonNulls
        .map((type) => type.element)
        .whereType<ClassElement>()
        .toList();

    // Проверяем, что все модули имеют аннотацию @Module
    for (final moduleElement in modules) {
      final hasModuleAnnotation = moduleElement.hasAnnotationOfType(Module);

      if (!hasModuleAnnotation) {
        throw InvalidGenerationSourceError(
          'Class ${moduleElement.name} must be annotated with @Module.',
          element: moduleElement,
        );
      }
    }

    return modules
        .map((e) => KnifeModule(
              name: e.name!,
              element: e,
            ))
        .toList();
  }

  Iterable<String> get imports => [
        element.library.identifier,
        ...modules.expand(
          (module) => [
            ...module.imports,
            module.element.library.identifier,
          ],
        ),
        ...providedTypes
            .map((type) => type.element)
            .whereType<ClassElement>()
            .map((e) => e.library.identifier)
      ].toSet();
}
