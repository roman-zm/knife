import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/dependency_graph_builder.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

class ComponentSpec {
  final ClassElement componentElement;
  final List<MethodElement> abstractMethods;
  final List<ClassElement> modules;
  final Map<DartType, KnifeProvider> providersByType;
  final Set<DartType> cachedTypes;
  final Set<DartType> dependencies;

  ComponentSpec._({
    required this.componentElement,
    required this.abstractMethods,
    required this.modules,
    required this.providersByType,
    required this.cachedTypes,
    required this.dependencies,
  });

  factory ComponentSpec(
    Element element,
    ConstantReader annotation,
  ) {
    try {
      return _createComponentSpec(element, annotation);
    } on InvalidGenerationSourceError catch (error) {
      if (error.element == null) {
        throw InvalidGenerationSourceError(error.message, element: element);
      }
      rethrow;
    }
  }

  String get generatedClassName => 'Knife${componentElement.name}';
}

ComponentSpec _createComponentSpec(
  Element element,
  ConstantReader annotation,
) {
  if (element is! ClassElement || !element.isAbstract) {
    throw InvalidGenerationSourceError(
      '`@Component` can only be used on abstract classes.',
    );
  }

  final modules = _getModulesFrom(annotation);
  final abstractMethods =
      element.methods.where((method) => method.isAbstract).toList();

  _validateAbstractMethods(abstractMethods);

  final providedTypes =
      abstractMethods.map((method) => method.returnType).toList();

  final dependencies = element.constructors.first.formalParameters
      .map((parameter) => parameter.type)
      .toSet();

  final providersByType =
      buildDependencyGraph(providedTypes, modules, dependencies);

  final cachedTypes = providersByType.values
      .where((provider) => provider.cached)
      .map((provider) => provider.type)
      .toSet();

  return ComponentSpec._(
    componentElement: element,
    abstractMethods: List.unmodifiable(abstractMethods),
    modules: List.unmodifiable(modules),
    providersByType: Map.unmodifiable(providersByType),
    cachedTypes: cachedTypes,
    dependencies: dependencies,
  );
}

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
  final modules = annotation
      .read('modules')
      .listValue
      .map((module) => module.toTypeValue())
      .nonNulls
      .map((type) => type.element)
      .whereType<ClassElement>()
      .toList();

  for (final module in modules) {
    if (!module.hasAnnotationOfType(Module)) {
      throw InvalidGenerationSourceError(
        'Class ${module.name} must be annotated with @Module.',
        element: module,
      );
    }
  }

  return modules;
}
