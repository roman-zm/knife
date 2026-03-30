import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:knife_generator/src/generator/component/dependency_graph_builder.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/model/node.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

class KnifeComponent {
  final ClassElement componentElement;
  final ConstantReader annotation;
  final List<MethodElement> abstractMethods;
  final List<DartType> providedTypes;
  final List<ClassElement> modules;
  final Map<DartType, KnifeProvider> providersByType;
  final Set<LibraryElement> libraries;
  final List<Node<DartType>> graphList;

  KnifeComponent._({
    required this.componentElement,
    required this.annotation,
    required this.abstractMethods,
    required this.providedTypes,
    required this.modules,
    required this.providersByType,
    required this.libraries,
    required this.graphList,
  });

  factory KnifeComponent(
    Element element,
    ConstantReader annotation,
  ) {
    try {
      return _createKnifeComponent(element, annotation);
    } on InvalidGenerationSourceError catch (e) {
      if (e.element == null) {
        throw InvalidGenerationSourceError(
          e.message,
          element: element,
        );
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

  final abstractMethods = element.methods.where((m) => m.isAbstract).toList();
  _validateAbstractMethods(abstractMethods);
  final providedTypes = abstractMethods.map((m) => m.returnType).toList();

  final modules = _getModulesFrom(annotation);

  final graphResult = _buildDependencyGraph(providedTypes, modules);
  final graphList = graphResult.graphList;
  final providersByType = graphResult.providersByType;

  final libraries = {
    element.library,
    ...modules.map((module) => module.library),
    ...providersByType.keys.map((type) => type.element?.library).nonNulls,
  };

  return KnifeComponent._(
    componentElement: element,
    annotation: annotation,
    abstractMethods: List.unmodifiable(abstractMethods),
    providedTypes: List.unmodifiable(providedTypes),
    modules: List.unmodifiable(modules),
    providersByType: Map.unmodifiable(providersByType),
    libraries: Set.unmodifiable(libraries),
    graphList: List.unmodifiable(graphList),
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

BuildGraphResult _buildDependencyGraph(
  List<DartType> providedTypes,
  List<ClassElement> modules,
) {
  return buildDependencyGraph(providedTypes, modules);
}
