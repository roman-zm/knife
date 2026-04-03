import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/generator/component/type_reference.dart';

List<Method> generateFactoryMethods(
  Map<DartType, KnifeProvider> providersByType,
) {
  return [
    for (final provider in providersByType.values)
      _generateFactoryMethod(provider),
  ];
}

Method _generateFactoryMethod(KnifeProvider provider) {
  return Method(
    (b) => b
      ..name = '_get${typeIdentifier(provider.type)}'
      ..returns = referType(provider.type)
      ..body = _generateMethodBody(provider),
  );
}

Code _generateMethodBody(KnifeProvider provider) {
  final variableName = '_${typeIdentifier(provider.type)}';
  final dependenciesMethods = provider.dependencies
      .map((dependency) => '_get${typeIdentifier(dependency)}');

  final providerMethodCall = refer(provider.methodName).call(
    dependenciesMethods.map(
      (methodName) => refer(methodName).call([]),
    ),
  );

  final body = switch (provider.cached) {
    true => refer('_cache.$variableName').assignNullAware(providerMethodCall),
    false => providerMethodCall,
  };

  return body.returned.statement;
}
