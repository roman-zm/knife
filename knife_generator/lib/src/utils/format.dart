import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

String formatCode(Spec spec, {bool scoped = false}) {
  final emitter = DartEmitter(
    useNullSafetySyntax: true,
    orderDirectives: true,
    allocator: scoped ? Allocator.none : Allocator.simplePrefixing(),
  );

  return DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  ).format('${spec.accept(emitter)}');
}
