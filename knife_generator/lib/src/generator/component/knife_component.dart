import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/dependency_graph_builder.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

class KnifeComponentCache {}

class KnifeComponent {
  final ClassElement componentElement;
  final List<MethodElement> abstractMethods;
  final List<DartType> providedTypes;
  final List<ClassElement> modules;
  final Map<DartType, KnifeProvider> providersByType;
  final Set<DartType> cachedTypes;

  KnifeComponent._({
    required this.componentElement,
    required this.abstractMethods,
    required this.providedTypes,
    required this.modules,
    required this.providersByType,
    required this.cachedTypes,
  });

  factory KnifeComponent(
    Element element,
    ConstantReader annotation,
  ) {
    try {
      return _createKnifeComponent(element, annotation);
    } on InvalidGenerationSourceError catch (e) {
      if (e.element == null) {
        throw InvalidGenerationSourceError(e.message, element: element);
      } else {
        rethrow;
      }
    }
  }

  String get generatedClassName => 'Knife${componentElement.name}';
}

KnifeComponent _createKnifeComponent(
  Element element,
  ConstantReader annotation,
) {
  if (element is! ClassElement || !element.isAbstract) {
    throw InvalidGenerationSourceError(
      '`@Component` can only be used on abstract classes.',
    );
  }
  final modules = _getModulesFrom(annotation);

  final abstractMethods = element.methods.where((m) => m.isAbstract).toList();
  _validateAbstractMethods(abstractMethods);

  final providedTypes = abstractMethods.map((m) => m.returnType).toList();
  final providersByType = buildDependencyGraph(providedTypes, modules);
  final cachedTypes = _getCachedTypes(providersByType);

  return KnifeComponent._(
    componentElement: element,
    abstractMethods: List.unmodifiable(abstractMethods),
    providedTypes: List.unmodifiable(providedTypes),
    modules: List.unmodifiable(modules),
    providersByType: Map.unmodifiable(providersByType),
    cachedTypes: cachedTypes,
  );
}

Set<DartType> _getCachedTypes(Map<DartType, KnifeProvider> providersByType) =>
    providersByType.values
        .where((provider) => provider.cached)
        .map((provider) => provider.type)
        .toSet();

void _validateAbstractMethods(List<MethodElement> abstractMethods) {
  for (final method in abstractMethods) {
    if (method.formalParameters.isNotEmpty) {
      throw InvalidGenerationSourceError(
        'Component method ${method.name} must not declare parameters.',
        element: method,
      );
    }
  }
}

List<ClassElement> _getModulesFrom(ConstantReader annotation) {
  final modulesReader = annotation.read('modules');
  final modules = modulesReader.listValue
      .map((module) => module.toTypeValue())
      .nonNulls
      .map((type) => type.element)
      .whereType<ClassElement>()
      .toList();

  _validateModules(modules);

  return modules;
}

void _validateModules(List<ClassElement> modules) {
  for (final moduleElement in modules) {
    final hasModuleAnnotation = moduleElement.hasAnnotationOfType(Module);

    if (!hasModuleAnnotation) {
      throw InvalidGenerationSourceError(
        'Class ${moduleElement.name} must be annotated with @Module.',
        element: moduleElement,
      );
    }
  }
}
