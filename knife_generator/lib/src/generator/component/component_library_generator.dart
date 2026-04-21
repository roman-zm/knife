import 'package:code_builder/code_builder.dart';

import 'component_spec.dart';
import 'factory_methods_generator.dart';
import 'module_fields_generator.dart';
import 'provider_methods_generator.dart';
import 'type_reference.dart';

class ComponentLibraryGenerator {
  final ComponentSpec component;

  ComponentLibraryGenerator(this.component);

  Library generate() {
    final cacheImplementation = _implementCacheClass();
    final dependenciesHolderImplementation =
        _implementDependenciesHolderClass();
    final componentImplementation = _implementComponentClass();

    return Library(
      (b) {
        b.body.add(componentImplementation);
        if (cacheImplementation != null) {
          b.body.add(cacheImplementation);
        }
        if (dependenciesHolderImplementation != null) {
          b.body.add(dependenciesHolderImplementation);
        }
      },
    );
  }

  Class _implementComponentClass() {
    Field getCacheField() => Field(
          (b) => b
            ..name = '_cache'
            ..type = refer('_Cache')
            ..modifier = FieldModifier.final$
            ..assignment = refer('_Cache').call([]).code,
        );
    Field getDependenciesField() => Field(
          (b) => b
            ..name = '_dependencies'
            ..type = refer('_Dependencies')
            ..modifier = FieldModifier.final$,
        );

    final fields = [
      ...getModuleFields(component.modules),
      if (component.cachedTypes.isNotEmpty) getCacheField(),
      if (component.dependencies.isNotEmpty) getDependenciesField(),
    ];
    final constructors = [
      if (component.dependencies.isNotEmpty) _implementComponentConstructor(),
    ];

    final providerMethods = generateProviderMethods(component.providersByType);
    final factoryMethods = generateFactoryMethods(component.providersByType);
    final implementedMethods = _implementAbstractMethods();

    return Class(
      (b) => b
        ..name = component.generatedClassName
        ..implements.add(
          refer(
            component.componentElement.name!,
            component.componentElement.library.identifier,
          ),
        )
        ..fields.addAll(fields)
        ..constructors.addAll(constructors)
        ..methods.addAll(implementedMethods)
        ..methods.addAll(factoryMethods)
        ..methods.addAll(providerMethods),
    );
  }

  Constructor _implementComponentConstructor() {
    final dependencies = component.dependencies.toList();

    return Constructor(
      (b) => b
        ..requiredParameters.addAll(
          dependencies.map(
            (dependency) => Parameter(
              (b) => b
                ..name = typeIdentifier(dependency)
                ..type = referType(dependency),
            ),
          ),
        )
        ..initializers.add(
          refer('_dependencies')
              .assign(
                refer('_Dependencies').call(
                  dependencies.map(
                    (dependency) => refer(typeIdentifier(dependency)),
                  ),
                ),
              )
              .code,
        ),
    );
  }

  List<Method> _implementAbstractMethods() {
    return [
      for (final method in component.abstractMethods)
        Method(
          (b) => b
            ..name = method.name
            ..returns = referType(method.returnType)
            ..annotations.add(CodeExpression(Code('override')))
            ..body = refer('_get${typeIdentifier(method.returnType)}')
                .call([])
                .returned
                .statement,
        )
    ];
  }

  Class? _implementCacheClass() {
    final cachedTypes = component.cachedTypes;

    if (cachedTypes.isEmpty) return null;

    return Class(
      (b) => b
        ..name = '_Cache'
        ..fields.addAll(
          cachedTypes.map(
            (type) => Field(
              (b) => b
                ..name = '_${typeIdentifier(type)}'
                ..type = TypeReference(
                  (tb) => tb
                    ..symbol = typeIdentifier(type)
                    ..url = type.element!.library!.identifier
                    ..isNullable = true,
                ),
            ),
          ),
        ),
    );
  }

  Class? _implementDependenciesHolderClass() {
    final dependencies = component.dependencies;

    if (dependencies.isEmpty) return null;

    final fields = dependencies
        .map(
          (dependency) => Field(
            (b) => b
              ..name = '_${typeIdentifier(dependency)}'
              ..type = referType(dependency)
              ..modifier = FieldModifier.final$,
          ),
        )
        .toList();

    final constructorParameters = dependencies
        .map(
          (dependency) => Parameter(
            (b) => b
              ..name = '_${typeIdentifier(dependency)}'
              ..toThis = true
              ..named = false,
          ),
        )
        .toList();

    return Class(
      (b) => b
        ..name = '_Dependencies'
        ..fields.addAll(fields)
        ..constructors.add(
          Constructor(
            (b) => b..requiredParameters.addAll(constructorParameters),
          ),
        ),
    );
  }
}
