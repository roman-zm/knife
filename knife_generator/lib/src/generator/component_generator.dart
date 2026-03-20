import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/generator/component/component_library_generator.dart';
import 'package:knife_generator/src/generator/component/knife_component.dart';
import 'package:source_gen/source_gen.dart';

class ComponentGenerator extends GeneratorForAnnotation<Component> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final componentClass = KnifeComponent(element, annotation);
    final library = ComponentLibraryGenerator().generate(componentClass);

    return _formatGeneratedCode(library);
  }

  String _formatGeneratedCode(Library library) {
    final emitter = DartEmitter(
      useNullSafetySyntax: true,
      orderDirectives: true,
    );

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format('${library.accept(emitter)}');
  }
}
