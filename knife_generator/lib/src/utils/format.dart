import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

String formatCode(Spec spec) {
  final emitter = DartEmitter(
    useNullSafetySyntax: true,
    orderDirectives: true,
  );

  return DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  ).format('${spec.accept(emitter)}');
}
