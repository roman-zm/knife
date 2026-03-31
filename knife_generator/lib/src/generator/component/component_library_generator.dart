import 'package:code_builder/code_builder.dart';
import 'package:knife_generator/src/generator/component/abstract_methods_generator.dart';
import 'package:knife_generator/src/generator/component/factory_methods_generator.dart';
import 'package:knife_generator/src/generator/component/knife_component.dart';
import 'package:knife_generator/src/generator/component/module_fields_generator.dart';

class ComponentLibraryGenerator {
  Library generate(KnifeComponent componentClass) {
    final classImplementation = _implementComponentClass(componentClass);

    return Library(
      (b) => b..body.add(classImplementation),
    );
  }

  Class _implementComponentClass(KnifeComponent component) {
    final componentName = component.componentElement.name!;

    final moduleFields = getModuleFields(component.modules);

    final factoryMethods = generateFactoryMethods(component.providersByType);

    final implementedMethods = implementAbstractMethods(component);

    return Class(
      (b) => b
        ..name = component.generatedClassName
        ..implements.add(
            refer(componentName, component.componentElement.library.identifier))
        ..fields.addAll(moduleFields)
        ..methods.addAll(implementedMethods)
        ..methods.addAll(factoryMethods),
    );
  }
}
