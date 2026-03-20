import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:knife_generator/src/generator/component/knife_component.dart';
import 'package:knife_generator/src/generator/component/method_wrapper.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/utils/get_module_fields.dart';
import 'package:source_gen/source_gen.dart';

import 'graph.dart';

class ComponentLibraryGenerator {
  Library generate(KnifeComponent componentClass) {
    final directives = componentClass.imports.map(Directive.import);
    final implClass = _implementComponentClass(componentClass);

    return Library(
      (b) => b
        ..body.add(implClass)
        ..directives.addAll(directives),
    );
  }

  Class _implementComponentClass(KnifeComponent component) {
    final graph = buildGraph(component);
    final componentName = component.element.name;

    final factoryMethods = _generateFactoryMethods(graph);
    final rootMethods = _generateRootMethods(component, graph);

    return Class(
      (b) => b
        ..name = component.generatedClassName
        ..implements.add(refer(componentName!))
        ..fields.addAll(getModuleFields(component.modules))
        ..methods.addAll(rootMethods)
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

  List<Method> _generateRootMethods(
    KnifeComponent component,
    DependencyGraph graph,
  ) {
    final abstractMethods = component.abstractMethods;

    final methods = <Method>[];
    for (final abstractMethod in abstractMethods) {
      final method = _generateRootMethod(abstractMethod, graph);
      methods.add(method);
    }
    return methods;
  }

  Method _generateRootMethod(
      MethodWrapper abstractMethod, DependencyGraph graph) {
    final methodName = abstractMethod.element.name;
    final returnType = abstractMethod.element.returnType;

    return Method(
      (b) => b
        ..name = methodName
        ..returns = refer(
          returnType.getDisplayString(),
        )
        ..annotations.add(CodeExpression(Code('override')))
        ..body = _generateRootMethodBody(returnType, graph),
    );
  }

  Code _generateRootMethodBody(DartType returnType, DependencyGraph graph) {
    final lines = <String>[];
    final variables = _getDependenciesList(graph, returnType);
    for (final variable in variables) {
      final providerMethodName = '_provide${_typeIdentifier(variable)}';
      final dependencies = graph[variable]?.dependencies ?? {};
      final parameters = dependencies
          .map((e) => '_${_typeIdentifier(e)}')
          .join(', ');
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

    final dependenciesSet = <DartType>[];

    while (dependenciesStack.isNotEmpty) {
      final currentType = dependenciesStack.removeLast();

      if (dependenciesSet.contains(currentType)) {
        continue;
      }

      dependenciesSet.add(currentType);

      final provider = graph[currentType];
      if (provider == null) {
        throw InvalidGenerationSourceError(
          'No provider found for type $currentType',
        );
      }

      dependenciesStack.addAll(provider.dependencies);
    }

    return dependenciesSet.reversed.toList();
  }

  String _typeIdentifier(DartType type) =>
      type.getDisplayString().replaceAll('?', '');
}
