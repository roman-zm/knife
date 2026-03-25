import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/graph.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

class KnifeComponent {
  final ClassElement componentElement;
  final ConstantReader annotation;
  final List<MethodElement> abstractMethods;
  final List<DartType> providedTypes;
  final List<ClassElement> modules;
  final DependencyGraph graph;
  final Set<LibraryElement> libraries;

  KnifeComponent._({
    required this.componentElement,
    required this.annotation,
    required this.abstractMethods,
    required this.providedTypes,
    required this.modules,
    required this.graph,
    required this.libraries,
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
  final providedTypes = abstractMethods.map((m) => m.returnType).toList();

  final modules = _getModulesFrom(annotation);
  final graph = _buildDependencyGraph(providedTypes, modules);

  final libraries = {
    element.library,
    ...modules.map((module) => module.library),
    ...graph.keys.map((type) => type.element?.library).nonNulls,
  };

  return KnifeComponent._(
    componentElement: element,
    annotation: annotation,
    abstractMethods: List.unmodifiable(abstractMethods),
    providedTypes: List.unmodifiable(providedTypes),
    modules: List.unmodifiable(modules),
    graph: Map.unmodifiable(graph),
    libraries: Set.unmodifiable(libraries),
  );
}

List<ClassElement> _getModulesFrom(ConstantReader annotation) {
  final modulesReader = annotation.read('modules');
  final modules = modulesReader.listValue
      .map((module) => module.toTypeValue())
      .map((type) => type?.element)
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

  return modules;
}

DependencyGraph _buildDependencyGraph(
  List<DartType> providedTypes,
  List<ClassElement> modules,
) {
  final DependencyGraph graph = {};

  final typesStack = [...providedTypes];
  while (typesStack.isNotEmpty) {
    final currentType = typesStack.removeLast();

    final provider = _getProviderForType(
      type: currentType,
      modules: modules,
    );

    graph[currentType] = provider;
    typesStack.addAll(provider.dependencies);
  }

  return graph;
}

KnifeProvider _getProviderForType({
  required DartType type,
  required List<ClassElement> modules,
}) {
  final moduleProviders = modules
      .map((module) => _getModuleProviderForType(module, type))
      .nonNulls
      .toList();

  // Должен быть не более одного провайдера, иначе это ошибка
  if (moduleProviders.length > 1) {
    throw InvalidGenerationSourceError(
      'Multiple providers found for type $type',
    );
  }

  if (moduleProviders.isNotEmpty) {
    return moduleProviders.first;
  }

  // Если провайдер не найден в модулях, то проверяем конструкторы класса
  final typeElement = type.element;
  if (typeElement is! ClassElement) {
    throw InvalidGenerationSourceError(
      'Type $type is not a class.',
    );
  }

  return InjectKnifeProvider(
    type,
    _findInjectAnnotatedConstructor(typeElement),
  );
}

KnifeProvider? _getModuleProviderForType(ClassElement module, DartType type) {
  final method = module.methods.firstWhereOrNull(
    (method) => method.returnType == type,
  );

  if (method != null) {
    return ModuleKnifeProvider(type, method);
  }

  return null;
}

ConstructorElement _findInjectAnnotatedConstructor(
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
