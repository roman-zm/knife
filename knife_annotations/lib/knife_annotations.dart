/// {@template inject_annotation}
/// Annotation for a constructor that tells the DI system
/// to use this constructor to create an instance.
/// {@endtemplate}
class Inject {
  /// {@macro inject_annotation}
  const Inject();
}

/// {@macro inject_annotation}
const inject = Inject();

/// {@template module_annotation}
/// Annotation for a class that contains dependency provider methods.
/// {@endtemplate}
class Module {
  /// {@macro module_annotation}
  const Module();
}

/// {@macro module_annotation}
const module = Module();

/// {@template provides_annotation}
/// Annotation for a method in a [Module] that provides a dependency.
/// {@endtemplate}
class Provides {
  /// {@macro provides_annotation}
  const Provides();
}

/// {@macro provides_annotation}
const provides = Provides();

/// {@template component_annotation}
/// Annotation for a component that wires modules and dependencies together.
/// {@endtemplate}
class Component {
  /// List of module types used by this component.
  final List<Type> modules;

  /// {@macro component_annotation}
  const Component({this.modules = const []});
}

/// {@template binds_annotation}
/// Annotation for a class or method that binds
/// an interface to its implementation.
/// {@endtemplate}
class Binds {
  /// {@macro binds_annotation}
  const Binds();
}

/// {@macro binds_annotation}
const binds = Binds();
