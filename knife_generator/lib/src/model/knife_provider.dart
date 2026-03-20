import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

sealed class KnifeProvider {
  final DartType type;

  KnifeProvider(this.type);

  Set<DartType> get dependencies;
}

class InjectKnifeProvider extends KnifeProvider {
  InjectKnifeProvider(super.type, this.constructor);

  final ConstructorElement constructor;

  @override
  Set<DartType> get dependencies {
    return constructor.formalParameters.map((param) => param.type).toSet();
  }
}

class ModuleKnifeProvider extends KnifeProvider {
  ModuleKnifeProvider(super.type, this.method);

  final MethodElement method;

  @override
  Set<DartType> get dependencies {
    return method.formalParameters.map((param) => param.type).toSet();
  }
}
