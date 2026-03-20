/// Аннотация для конструктора, указывающая, что система DI
/// должна использовать его для создания экземпляра.
class Inject {
  const Inject();
}

const inject = Inject();

/// Аннотация для класса, который содержит методы, предоставляющие зависимости.

class Module {
  const Module();
}

const module = Module();

/// Аннотация для метода в @Module, который предоставляет зависимость.
class Provides {
  const Provides();
}

const provides = Provides();

/// Аннотация для компонента, который связывает модули и зависимости.
class Component {
  final List<Type> modules;
  const Component({this.modules = const []});
}

/// Аннотация для класса, который связывает интерфейс с реализацией.
class Binds {
  const Binds();
}

const binds = Binds();
