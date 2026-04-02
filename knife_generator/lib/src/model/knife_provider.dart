import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

sealed class KnifeProvider {
  final DartType type;
  final bool cached;

  KnifeProvider(this.type, this.cached);

  Set<DartType> get dependencies;

  String get methodName => '_create${type.element?.displayName}';
}

class InjectKnifeProvider extends KnifeProvider {
  InjectKnifeProvider(super.type, super.cached, this.constructor);

  final ConstructorElement constructor;

  @override
  Set<DartType> get dependencies {
    return constructor.formalParameters.map((param) => param.type).toSet();
  }
}

class ModuleKnifeProvider extends KnifeProvider {
  ModuleKnifeProvider(super.type, super.cached, this.method);

  final MethodElement method;

  @override
  Set<DartType> get dependencies {
    return method.formalParameters.map((param) => param.type).toSet();
  }
}
