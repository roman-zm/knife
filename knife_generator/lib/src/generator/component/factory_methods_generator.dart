import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:knife_generator/src/model/knife_provider.dart';

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
      ..name = '_get${provider.type.element?.displayName}'
      ..returns = refer(
        provider.type.element!.displayName,
        provider.type.element!.library!.identifier,
      )
      ..body = _generateMethodBody(provider),
  );
}

Code _generateMethodBody(KnifeProvider provider) {
  final variableName = '_${provider.type.element?.displayName}';
  final dependenciesMethods =
      provider.dependencies.map((e) => '_get${e.element?.displayName}');

  final providerMethodCall = refer(provider.methodName).call(
    dependenciesMethods.map(
      (e) => refer(e).call([]),
    ),
  );

  final body = switch (provider.cached) {
    true => refer('_cache.$variableName').assignNullAware(providerMethodCall),
    false => providerMethodCall,
  };

  return body.returned.statement;
}
