import 'package:build/build.dart';
import 'package:knife_generator/src/generator/module_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Генератор для модулей, создаёт реализацию абстрактного класса модуля
Builder moduleBuilder(BuilderOptions options) {
  const header =
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n// ignore_for_file: unused_element\n';

  return PartBuilder(
    [ModuleGenerator()],
    '.module.dart',
    header: header,
  );
}
