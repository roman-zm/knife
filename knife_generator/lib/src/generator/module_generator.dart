import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:knife_annotations/knife_annotations.dart';
import 'package:knife_generator/src/utils/element_ext.dart';
import 'package:knife_generator/src/utils/format.dart';
import 'package:source_gen/source_gen.dart';

class ModuleGenerator extends GeneratorForAnnotation<Module> {
  @override
  String? generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Module` can only be used on classes.',
        element: element,
      );
    }

    if (!element.isAbstract) {
      final hasBindsMethods =
          element.methods.any((method) => method.hasAnnotationOfType(Binds));

      if (hasBindsMethods) {
        throw InvalidGenerationSourceError(
          'Classes annotated with @Module that contain @Binds methods must be abstract.',
          element: element,
        );
      } else {
        return null;
      }
    }

    final knifeModuleClass = Class(
      (b) {
        final elementName = element.name!;
        b.name = 'Knife$elementName';

        final isInterfaceClass = element.isInterface;
        if (isInterfaceClass) {
          b.implements.add(refer(elementName));
        } else {
          final hasPrivateNoNameConstructor = element.constructors
              .any((constructor) => constructor.name == '_');

          if (!hasPrivateNoNameConstructor) {
            final hasNonAbstractMethods =
                element.methods.any((method) => !method.isAbstract);
            if (hasNonAbstractMethods) {
              throw InvalidGenerationSourceError(
                'Classes annotated with @Module must have a private unnamed constructor if they contain non-abstract methods.',
                element: element,
              );
            }
            b.implements.add(refer(elementName));
          } else {
            b.extend = refer(elementName);
            b.constructors.add(Constructor(
              (cb) => cb
                // ..name = 'Knife${element.name}'
                ..initializers.add(Code('super._()')),
            ));
          }
        }

        b
          ..name = 'Knife$elementName'
          ..methods.addAll([
            for (final method in element.methods)
              if (method.isAbstract) _implementMethod(method),
          ]);
      },
    );

    return formatCode(knifeModuleClass);
  }

  Method _implementMethod(MethodElement method) {
    if (!method.hasAnnotationOfType(Binds)) {
      throw InvalidGenerationSourceError(
        'Only methods annotated with @Binds can be implemented in a module.',
        element: method,
      );
    }

    if (method.formalParameters.length != 1) {
      throw InvalidGenerationSourceError(
        '@Binds method must have exactly one parameter.',
        element: method,
      );
    }

    final param = method.formalParameters.first;
    final paramName = param.name;

    return Method(
      (mb) => mb
        ..name = method.name
        ..returns = refer(
          method.returnType.getDisplayString(),
        )
        ..annotations.add(refer('override'))
        ..requiredParameters.add(Parameter(
          (pb) => pb
            ..name = param.name!
            ..type = refer(
              param.type.getDisplayString(),
            ),
        ))
        ..body = Code('return $paramName;'),
    );
  }
}
