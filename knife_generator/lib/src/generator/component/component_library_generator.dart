import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:knife_generator/src/generator/component/knife_component.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:source_gen/source_gen.dart';

import 'graph.dart';

class ComponentLibraryGenerator {
  Library generate(KnifeComponent componentClass) {
    final classImplementation = _implementComponentClass(componentClass);

    final directives = componentClass.libraries
        .map((library) => library.identifier)
        .map(Directive.import);

    return Library(
      (b) => b
        ..body.add(classImplementation)
        ..directives.addAll(directives),
    );
  }

  Class _implementComponentClass(KnifeComponent component) {
    final componentName = component.componentElement.name!;

    final moduleFields = getModuleFields(component.modules);

    final implementedMethods = _implementAbstractMethods(component);
    final factoryMethods = _generateFactoryMethods(component.graph);

    return Class(
      (b) => b
        ..name = component.generatedClassName
        ..implements.add(refer(componentName))
        ..fields.addAll(moduleFields)
        ..methods.addAll(implementedMethods)
        ..methods.addAll(factoryMethods),
    );
  }

  List<Method> _generateFactoryMethods(DependencyGraph graph) {
    final methods = <Method>[];
    for (final entry in graph.entries) {
      final returnType = entry.key;
      final provider = entry.value;

      final providerMethod = _generateProviderMethod(returnType, provider);
      methods.add(providerMethod);
    }
    return methods;
  }

  Method _generateProviderMethod(DartType returnType, KnifeProvider provider) {
    final methodName = '_provide${_typeIdentifier(returnType)}';
    final parameters = provider.dependencies.map((e) {
      return Parameter((b) => b
        ..name = '_${_typeIdentifier(e)}'
        ..type = refer(e.getDisplayString()));
    }).toList();

    final method = Method(
      (b) => b
        ..name = methodName
        ..returns = refer(
          returnType.getDisplayString(),
        )
        ..requiredParameters.addAll(parameters)
        ..body = _generateProviderMethodBody(provider),
    );
    return method;
  }

  Code _generateProviderMethodBody(KnifeProvider provider) {
    return switch (provider) {
      InjectKnifeProvider injectProvider =>
        _generateInjectProviderMethodBody(injectProvider),
      ModuleKnifeProvider moduleProvider =>
        _generateModuleProviderMethodBody(moduleProvider),
    };
  }

  Code _generateInjectProviderMethodBody(InjectKnifeProvider injectProvider) {
    final constructor = injectProvider.constructor;
    final returnTypeElement = constructor.enclosingElement;
    final constructorNameValue = constructor.name;
    final constructorName =
        constructorNameValue == null || constructorNameValue == 'new'
            ? '${returnTypeElement.name}'
            : '${returnTypeElement.name}.$constructorNameValue';

    final parameters = constructor.formalParameters
        .map((param) => '_${_typeIdentifier(param.type)}')
        .join(', ');

    return Code('return $constructorName($parameters);');
  }

  Code _generateModuleProviderMethodBody(ModuleKnifeProvider moduleProvider) {
    final method = moduleProvider.method;
    final methodName = method.name;

    final module = method.enclosingElement;
    final moduleName = module?.name;
    if (moduleName == null) {
      throw InvalidGenerationSourceError(
        'Method $methodName must be declared inside a named module class.',
        element: method,
      );
    }
    final methodFieldName = '_$moduleName';

    final parameters = method.formalParameters
        .map((param) => '_${_typeIdentifier(param.type)}')
        .join(', ');

    return Code('return $methodFieldName.$methodName($parameters);');
  }

  List<Method> _implementAbstractMethods(KnifeComponent component) {
    final abstractMethods = component.abstractMethods;

    final methods = <Method>[];
    for (final abstractMethod in abstractMethods) {
      final method = _implementAbstractMethod(abstractMethod, component.graph);
      methods.add(method);
    }
    return methods;
  }

  Method _implementAbstractMethod(
    MethodElement abstractMethod,
    DependencyGraph graph,
  ) {
    final methodName = abstractMethod.name;
    final returnType = abstractMethod.returnType;

    return Method(
      (b) => b
        ..name = methodName
        ..returns = refer(returnType.getDisplayString())
        ..annotations.add(CodeExpression(Code('override')))
        ..body = _generateAbstractMethodBody(returnType, graph),
    );
  }

  Code _generateAbstractMethodBody(DartType returnType, DependencyGraph graph) {
    final lines = <String>[];
    final variables = _getDependenciesList(graph, returnType);
    for (final variable in variables) {
      final providerMethodName = '_provide${_typeIdentifier(variable)}';
      final dependencies = graph[variable]?.dependencies ?? {};
      final parameters =
          dependencies.map((e) => '_${_typeIdentifier(e)}').join(', ');

      lines.add(
          'final _${_typeIdentifier(variable)} = $providerMethodName($parameters);');
    }
    lines.add(
      'return _${_typeIdentifier(returnType)};',
    );

    return Code(lines.join('\n'));
  }

  List<DartType> _getDependenciesList(
    DependencyGraph graph,
    DartType returnType,
  ) {
    final dependenciesStack = [
      returnType,
    ];

    final dependenciesList = <DartType>[];

    while (dependenciesStack.isNotEmpty) {
      final currentType = dependenciesStack.removeAt(0);

      if (dependenciesList.contains(currentType)) {
        continue;
      }

      dependenciesList.add(currentType);

      final provider = graph[currentType];
      if (provider == null) {
        throw InvalidGenerationSourceError(
          'No provider found for type $currentType',
        );
      }

      dependenciesStack.addAll(provider.dependencies);
    }

    return dependenciesList.reversed.toList();
  }

  String _typeIdentifier(DartType type) =>
      type.getDisplayString().replaceAll('?', '');
}

Iterable<Field> getModuleFields(List<ClassElement> modules) {
  return modules.map(_getModuleField);
}

Field _getModuleField(ClassElement module) {
  final defaultConstructor = _chooseConstructor(module);
  final constructorNameValue = defaultConstructor.name;

  // Формируем код для создания экземпляра
  final constructorName =
      constructorNameValue == null || constructorNameValue == 'new'
          ? '${module.name}()'
          : '${module.name}.$constructorNameValue()';

  final assignment = Code(constructorName);

  return Field(
    (b) => b
      ..name = '_${module.name}'
      ..type = refer(module.name!)
      ..modifier = FieldModifier.final$ // Поле должно быть final
      ..assignment = assignment,
  );
}

ConstructorElement _chooseConstructor(ClassElement element) {
  // Находим конструкторы элемента
  final constructors = element.constructors;

  // Ищем конструктор без аргументов
  final noArgConstructors = constructors.where(
    (constructor) => constructor.formalParameters.isEmpty,
  );

  final defaultConstructor = constructors.firstWhereOrNull(
    (constructor) => constructor.isDefaultConstructor,
  );
  final constructor = defaultConstructor ?? noArgConstructors.firstOrNull;

  if (constructor == null) {
    throw InvalidGenerationSourceError(
      'Class ${element.name} must have a constructor without arguments.',
      element: element,
    );
  }
  return constructor;
}
