import 'package:build/build.dart';
import 'package:knife_generator/src/generator/component_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Генератор для компонентов, создаёт реализацию абстрактного класса компонента
Builder componentGenerator(BuilderOptions options) {
  const header =
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n// ignore_for_file: unused_element, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, prefer_const_constructors\n';

  return LibraryBuilder(
    ComponentGenerator(),
    generatedExtension: '.component.dart',
    header: header,
  );
}
