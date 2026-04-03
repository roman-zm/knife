import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:knife_generator/src/generator/component/type_reference.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:source_gen/source_gen.dart';

List<Method> generateProviderMethods(
  Map<DartType, KnifeProvider> providersByType,
) {
  final methods = <Method>[];
  for (final entry in providersByType.entries) {
    final returnType = entry.key;
    final provider = entry.value;

    final providerMethod = _generateProviderMethod(returnType, provider);
    methods.add(providerMethod);
  }
  return methods;
}

Method _generateProviderMethod(DartType returnType, KnifeProvider provider) {
  final methodName = provider.methodName;
  final parameters = provider.dependencies.map((dependency) {
    return Parameter(
      (b) => b
        ..name = '_${typeIdentifier(dependency)}'
        ..type = referType(dependency),
    );
  }).toList();

  final method = Method(
    (b) => b
      ..name = methodName
      ..returns = referType(returnType)
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

  final constructorCall = refer(
    constructor.displayName,
    constructor.library.identifier,
  ).call(
    [
      for (final param in constructor.formalParameters)
        refer('_${typeIdentifier(param.type)}'),
    ],
  );

  return constructorCall.returned.statement;
}

Code _generateModuleProviderMethodBody(ModuleKnifeProvider moduleProvider) {
  final method = moduleProvider.method;
  final methodName = method.displayName;

  final module = method.enclosingElement;
  final moduleName = module?.name;
  if (moduleName == null) {
    throw InvalidGenerationSourceError(
      'Method $methodName must be declared inside a named module class.',
      element: method,
    );
  }

  return refer('_$moduleName.$methodName')
      .call(
        [
          for (final param in method.formalParameters)
            refer('_${typeIdentifier(param.type)}'),
        ],
      )
      .returned
      .statement;
}
