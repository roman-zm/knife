import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:knife_generator/src/generator/component/knife_component.dart';
import 'package:knife_generator/src/model/knife_provider.dart';
import 'package:knife_generator/src/model/node.dart';

List<Method> implementAbstractMethods(KnifeComponent component) {
  final abstractMethods = component.abstractMethods;
  final graphList = component.graphList;

  final methods = <Method>[];
  for (final abstractMethod in abstractMethods) {
    final returnType = abstractMethod.returnType;
    final graph = graphList.firstWhere(
      (g) => g.value == returnType,
    );
    final method = _implementAbstractMethod(
      abstractMethod,
      component.providersByType,
      graph,
    );
    methods.add(method);
  }
  return methods;
}

Method _implementAbstractMethod(
  MethodElement abstractMethod,
  Map<DartType, KnifeProvider> providersByType,
  Node<DartType> graph,
) {
  final methodName = abstractMethod.name;
  final returnType = abstractMethod.returnType;

  return Method(
    (b) => b
      ..name = methodName
      ..returns = refer(
        returnType.getDisplayString(),
        returnType.element?.library?.identifier,
      )
      ..annotations.add(CodeExpression(Code('override')))
      ..body = _generateAbstractMethodBody(graph, providersByType),
  );
}

Code _generateAbstractMethodBody(
  Node<DartType> graph,
  Map<DartType, KnifeProvider> providersByType,
) {
  final lines = <String>[];
  final variables = _getDependenciesList(graph);

  for (final variable in variables) {
    final providerMethodName = '_provide${variable.element?.displayName}';
    final dependencies = providersByType[variable]?.dependencies ?? {};
    final parameters =
        dependencies.map((e) => '_${e.element?.displayName}').join(', ');

    lines.add(
      'final _${variable.element?.displayName} = $providerMethodName($parameters);',
    );
  }

  final returnType = graph.value;
  lines.add(
    'return _${returnType.element?.displayName};',
  );

  return Code(lines.join('\n'));
}

List<DartType> _getDependenciesList(Node<DartType> graph) {
  final dependenciesList = <DartType>[];
  final visited = <DartType>{};

  void visit(Node<DartType> node) {
    if (!visited.add(node.value)) {
      return;
    }

    for (final child in node.children) {
      visit(child);
    }

    dependenciesList.add(node.value);
  }

  visit(graph);

  return dependenciesList;
}
