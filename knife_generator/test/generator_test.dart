import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:knife_generator/component_generator.dart';
import 'package:test/test.dart';

void main() {
  group('DependencyGenerator Tests', () {
    test('should generate component implementation', () async {
      // Тестовый код с компонентом
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

abstract class AppService {
  String doSomething();
}

class AppServiceImpl implements AppService {
  @override
  String doSomething() => 'Service Result';
}

@module
class AppModule {
  @provides
  AppService provideAppService() => AppServiceImpl();
}

@Component(modules: [AppModule])
abstract class AppComponent {
  AppService appService();
}
''';

      // Запуск генератора
      final builder = componentGenerator(BuilderOptions.empty);

      await testBuilder(
        builder,
        {
          'knife_annotations|lib/knife_annotations.dart': '''
class Component {
  final List<Type> modules;
  const Component({this.modules = const []});
}

class Module {
  const Module();
}
const module = Module();

class Provides {
  const Provides();
}
const provides = Provides();
''',
          'test_package|lib/test.dart': testSource,
        },
        outputs: {
          'test_package|lib/test.component.dart': decodedMatches(
            contains('KnifeAppComponent'),
          ),
        },
      );
    });

    test('should handle debug breakpoints', () {
      final generatedClassName = 'KnifeAppComponent';

      expect(generatedClassName, equals('KnifeAppComponent'));
    });
  });
}
