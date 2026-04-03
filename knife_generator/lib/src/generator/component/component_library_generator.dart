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
    final componentImplementation = _implementComponentClass();
    final cacheImplementation = _implementCacheClass();

    return Library(
      (b) {
        b.body.add(componentImplementation);
        if (cacheImplementation != null) {
          b.body.add(cacheImplementation);
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

    final fields = [
      ...getModuleFields(component.modules),
      if (component.cachedTypes.isNotEmpty) getCacheField(),
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
        ..methods.addAll(implementedMethods)
        ..methods.addAll(factoryMethods)
        ..methods.addAll(providerMethods),
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
}
