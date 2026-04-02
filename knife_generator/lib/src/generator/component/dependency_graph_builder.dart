import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/model/node.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

ProvidersByType buildDependencyGraph(
  List<DartType> providedTypes,
  List<ClassElement> modules,
) {
  return _DependencyGraphBuilder(modules).build(providedTypes);
}

typedef ProvidersByType = Map<DartType, KnifeProvider>;

class _DependencyGraphBuilder {
  final List<ClassElement> modules;
  final Map<DartType, KnifeProvider> _providers = {};
  final Map<DartType, Node<DartType>> _nodeCache = {};

  _DependencyGraphBuilder(this.modules);

  ProvidersByType build(List<DartType> providedTypes) {
    _providers.clear();
    _nodeCache.clear();

    providedTypes.map((type) => _traverse(type, {})).toList();

    return _providers;
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
        .map((module) => _getModuleProvider(module, type))
        .nonNulls
        .toList();

    if (moduleProviders.length > 1) {
      throw InvalidGenerationSourceError(
        _multipleProvidersMessage(type, moduleProviders),
        element: moduleProviders.first.method,
      );
    }

    if (moduleProviders.isNotEmpty) {
      final moduleProvider = moduleProviders.first;
      final cached = moduleProvider.method.hasAnnotationOfType(Cached);
      return ModuleKnifeProvider(
        type,
        cached,
        moduleProvider.method,
      );
    }

    final typeElement = type.element;
    if (typeElement is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Type $type is not a class.',
      );
    }

    final constructor = _findInjectAnnotatedConstructor(typeElement);
    final cached = constructor.hasAnnotationOfType(Cached);

    return InjectKnifeProvider(type, cached, constructor);
  }

  ModuleKnifeProvider? _getModuleProvider(
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

    final cached = method.hasAnnotationOfType(Cached);

    return ModuleKnifeProvider(type, cached, method);
  }

  String _multipleProvidersMessage(
    DartType type,
    List<ModuleKnifeProvider> candidates,
  ) {
    final formattedCandidates = candidates
        .map(
          (candidate) =>
              '${candidate.method.enclosingElement!.name}.${candidate.method.name}',
        )
        .join(', ');

    return 'Multiple providers found for type $type: $formattedCandidates.';
  }
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
