import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/component_library_generator.dart';
import 'package:knife_generator/src/generator/component/component_spec.dart';
import 'package:knife_generator/src/utils/format.dart';
import 'package:source_gen/source_gen.dart';

class ComponentGenerator extends GeneratorForAnnotation<Component> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final componentSpec = ComponentSpec(element, annotation);
    final library = ComponentLibraryGenerator(componentSpec).generate();

    return formatCode(library, scoped: true);
  }
}
