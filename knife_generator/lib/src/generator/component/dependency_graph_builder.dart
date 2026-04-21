import 'dart:developer';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/type_reference.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:source_gen/source_gen.dart';

ProvidersByType buildDependencyGraph(
  List<DartType> providedTypes,
  List<ClassElement> modules,
  Set<DartType> dependencies,
) {
  return _DependencyGraphBuilder(modules, dependencies).build(providedTypes);
}

typedef ProvidersByType = Map<DartType, KnifeProvider>;

class _DependencyGraphBuilder {
  final List<ClassElement> modules;
  final Set<DartType> dependencies;
  final Map<DartType, KnifeProvider> _providers = {};
  final Set<DartType> _resolvedTypes = {};

  _DependencyGraphBuilder(this.modules, this.dependencies);

  ProvidersByType build(List<DartType> providedTypes) {
    _providers.clear();
    _resolvedTypes.clear();

    log('Building dependency graph for provided types: ${providedTypes.map((type) => type.getDisplayString()).join(', ')}');
    log('Modules: ${modules.map((module) => module.name).join(', ')}');
    log('External dependencies: ${dependencies.map((type) => type.getDisplayString()).join(', ')}');

    for (final type in providedTypes) {
      _traverse(type, <DartType>[]);
    }

    return _providers;
  }

  void _traverse(DartType type, List<DartType> path) {
    ensureSupportedType(type);

    if (path.contains(type)) {
      throw InvalidGenerationSourceError(
        'Cyclic dependency detected: ${[
          ...path,
          type,
        ].map((item) => item.getDisplayString()).join(' -> ')}',
      );
    }

    if (_resolvedTypes.contains(type)) {
      return;
    }

    final provider = _getProviderForType(type);
    _providers[type] = provider;

    final nextPath = [...path, type];
    for (final dependency in provider.dependencies) {
      _traverse(dependency, nextPath);
    }

    _resolvedTypes.add(type);
  }

  KnifeProvider _getProviderForType(DartType type) {
    ensureSupportedType(type);

    final cachedProvider = _providers[type];
    if (cachedProvider != null) {
      return cachedProvider;
    }

    final isExternalDependency = dependencies.contains(type);
    if (isExternalDependency) {
      return _getExternalDependencyProvider(type);
    }

    final moduleProviders = _findModuleProvidersFor(type);
    if (moduleProviders.length > 1) {
      throw InvalidGenerationSourceError(
        _multipleProvidersMessage(type, moduleProviders),
        element: moduleProviders.first.method,
      );
    } else if (moduleProviders.length == 1) {
      return moduleProviders.first;
    }

    final injectConstructors = _findInjectAnnotatedConstructors(type);
    if (injectConstructors.length == 1) {
      final constructor = injectConstructors.first;
      return _getInjectConstructorProvider(constructor, type);
    }

    throw InvalidGenerationSourceError(
      _getNoProvidersFoundMessage(type),
      element: type.element,
    );
  }

  String _getNoProvidersFoundMessage(DartType type) {
    return '''No provider found for type ${type.getDisplayString()}. To resolve this, ensure that:
 - A module provides this type via @Provides or @Binds.
 - The class has exactly one constructor annotated with @Inject.
 - The type is explicitly listed as a dependency in a Component constructor.''';
  }

  InjectKnifeProvider _getInjectConstructorProvider(
      ConstructorElement constructor, DartType type) {
    final cached = constructor.hasAnnotationOfType(Cached);
    return InjectKnifeProvider(type, cached, constructor);
  }

  List<ModuleKnifeProvider> _findModuleProvidersFor(DartType type) {
    return modules
        .map((module) => _getModuleProvider(module, type))
        .nonNulls
        .toList();
  }

  ExternalDependencyKnifeProvider _getExternalDependencyProvider(
      DartType type) {
    return ExternalDependencyKnifeProvider(type);
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

List<ConstructorElement> _findInjectAnnotatedConstructors(DartType type) {
  final returnTypeElement = type.element;
  if (returnTypeElement is! ClassElement) {
    throw InvalidGenerationSourceError(
      'Type $type is not a class.',
    );
  }

  final injectConstructors = returnTypeElement.constructors
      .where((constructor) => constructor.hasAnnotationOfType(Inject))
      .toList();

  return injectConstructors;
}
