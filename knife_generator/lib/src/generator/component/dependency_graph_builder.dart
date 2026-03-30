import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/model/node.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

BuildGraphResult buildDependencyGraph(
  List<DartType> providedTypes,
  List<ClassElement> modules,
) {
  return _DependencyGraphBuilder(modules).build(providedTypes);
}

class _BuildGraphResult {
  final List<Node<DartType>> graphList;
  final Map<DartType, KnifeProvider> providersByType;

  _BuildGraphResult({
    required this.graphList,
    required this.providersByType,
  });
}

typedef BuildGraphResult = _BuildGraphResult;

class _DependencyGraphBuilder {
  final List<ClassElement> modules;
  final Map<DartType, KnifeProvider> _providers = {};
  final Map<DartType, Node<DartType>> _nodeCache = {};

  _DependencyGraphBuilder(this.modules);

  _BuildGraphResult build(List<DartType> providedTypes) {
    _providers.clear();
    _nodeCache.clear();

    final graphList = providedTypes.map((type) => _traverse(type, {})).toList();

    return _BuildGraphResult(
      graphList: graphList,
      providersByType: _providers,
    );
  }

  Node<DartType> _traverse(DartType type, Set<DartType> path) {
    if (path.contains(type)) {
      throw InvalidGenerationSourceError(
        'Cyclic dependency detected: ${[
          ...path,
          type
        ].map((t) => t.getDisplayString()).join(' -> ')}',
      );
    }

    final cachedNode = _nodeCache[type];
    if (cachedNode != null) {
      return cachedNode;
    }

    final provider = _getProviderForType(type);
    _providers[type] = provider;

    final node = Node(
      type,
      provider.dependencies
          .map((dependency) => _traverse(dependency, {...path, type}))
          .toList(),
    );

    _nodeCache[type] = node;
    return node;
  }

  KnifeProvider _getProviderForType(DartType type) {
    final cachedProvider = _providers[type];
    if (cachedProvider != null) {
      return cachedProvider;
    }

    final moduleProviders = modules
        .map((module) => _getModuleProviderCandidate(module, type))
        .nonNulls
        .toList();

    if (moduleProviders.length > 1) {
      throw InvalidGenerationSourceError(
        _multipleProvidersMessage(type, moduleProviders),
        element: moduleProviders.first.method,
      );
    }

    if (moduleProviders.isNotEmpty) {
      return ModuleKnifeProvider(type, moduleProviders.first.method);
    }

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

  _ModuleProviderCandidate? _getModuleProviderCandidate(
    ClassElement module,
    DartType type,
  ) {
    final methods = module.methods
        .where(
          (method) =>
              !method.isPrivate &&
              method.returnType == type &&
              (method.hasAnnotationOfType(Provides) ||
                  method.hasAnnotationOfType(Binds)),
        )
        .toList();

    if (methods.length > 1) {
      final methodNames = methods.map((method) => method.name).join(', ');
      throw InvalidGenerationSourceError(
        'Module ${module.name} has multiple providers for type $type: '
        '$methodNames.',
        element: module,
      );
    }

    final method = methods.firstOrNull;
    if (method == null) {
      return null;
    }

    return _ModuleProviderCandidate(module: module, method: method);
  }

  String _multipleProvidersMessage(
    DartType type,
    List<_ModuleProviderCandidate> candidates,
  ) {
    final formattedCandidates = candidates
        .map(
          (candidate) => '${candidate.module.name}.${candidate.method.name}',
        )
        .join(', ');

    return 'Multiple providers found for type $type: $formattedCandidates.';
  }
}

class _ModuleProviderCandidate {
  final ClassElement module;
  final MethodElement method;

  _ModuleProviderCandidate({
    required this.module,
    required this.method,
  });
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
