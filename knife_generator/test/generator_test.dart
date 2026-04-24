import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:knife_generator/component_library_builder.dart';
import 'package:test/test.dart';

const _knifeAnnotationsSource = '''
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

class Inject {
  const Inject();
}
const inject = Inject();

class Binds {
  const Binds();
}
const binds = Binds();
''';

const _fakeAnnotationsSource = '''
class Inject {
  const Inject();
}
''';

Future<void> _runBuilder(
  String source, {
  Map<String, Object> extraAssets = const {},
  Map<String, Matcher> outputs = const {},
  void Function(String log)? onLog,
}) {
  final builder = componentLibraryBuilder(BuilderOptions.empty);

  return testBuilder(
    builder,
    {
      'knife_annotations|lib/knife_annotations.dart': _knifeAnnotationsSource,
      'test_package|lib/test.dart': source,
      ...extraAssets,
    },
    outputs: outputs,
    onLog: onLog == null ? null : (record) => onLog(record.toString()),
  );
}

void main() {
  group('ComponentGenerator', () {
    test('generates component implementation', () async {
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

      await _runBuilder(
        testSource,
        outputs: {
          'test_package|lib/test.component.dart': decodedMatches(
            allOf([
              contains('class KnifeAppComponent implements _i1.AppComponent'),
              contains('return _AppModule.provideAppService();'),
            ]),
          ),
        },
      );
    });

    test('fails fast for parameterized dependency types', () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

class Item {
  @inject
  Item();
}

class GenericService {
  @inject
  GenericService(List<Item> items);
}

@module
class AppModule {
  @provides
  List<Item> provideItems(Item item) => [item];
}

@Component(modules: [AppModule])
abstract class AppComponent {
  GenericService genericService();
}
''';

      final logs = <String>[];
      await _runBuilder(
        testSource,
        onLog: logs.add,
      );

      expect(
        logs,
        contains(
          contains('Parameterized types are not supported: List<Item>.'),
        ),
      );
    });

    test('reuses shared dependency subgraphs across component roots', () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

class SharedDependency {
  @inject
  SharedDependency();
}

class FeatureA {
  @inject
  FeatureA(SharedDependency sharedDependency);
}

class FeatureB {
  @inject
  FeatureB(SharedDependency sharedDependency);
}

class RootService {
  @inject
  RootService(FeatureA featureA, FeatureB featureB);
}

@Component()
abstract class AppComponent {
  RootService rootService();
}
''';

      await _runBuilder(
        testSource,
        outputs: {
          'test_package|lib/test.component.dart': decodedMatches(
            allOf([
              contains('return _createFeatureA(_getSharedDependency());'),
              contains('return _createFeatureB(_getSharedDependency());'),
              contains(
                'return _i1.RootService(_FeatureA, _FeatureB);',
              ),
            ]),
          ),
        },
      );
    });

    test('ignores non-annotated module helpers when searching providers',
        () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

abstract class AppService {}

class AppServiceImpl implements AppService {
  @inject
  AppServiceImpl();
}

@module
class AppModule {
  AppService helperService() => AppServiceImpl();

  @provides
  AppService provideAppService() => AppServiceImpl();
}

@Component(modules: [AppModule])
abstract class AppComponent {
  AppService appService();
}
''';

      await _runBuilder(
        testSource,
        outputs: {
          'test_package|lib/test.component.dart': decodedMatches(
            allOf([
              contains('return _AppModule.provideAppService();'),
              isNot(contains('helperService')),
            ]),
          ),
        },
      );
    });

    test('fails with a clear error on cyclic dependencies', () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

class ServiceA {
  @inject
  ServiceA(ServiceB serviceB);
}

class ServiceB {
  @inject
  ServiceB(ServiceA serviceA);
}

@Component()
abstract class AppComponent {
  ServiceA serviceA();
}
''';

      final logs = <String>[];
      await _runBuilder(
        testSource,
        onLog: logs.add,
      );

      expect(
        logs,
        contains(contains(
            'Cyclic dependency detected: ServiceA -> ServiceB -> ServiceA')),
      );
    });

    test('fails when a component method declares parameters', () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

class AppService {
  @inject
  AppService();
}

@Component()
abstract class AppComponent {
  AppService appService(String scope);
}
''';

      final logs = <String>[];
      await _runBuilder(
        testSource,
        onLog: logs.add,
      );

      expect(
        logs,
        contains(
          contains('Component method appService must not declare parameters.'),
        ),
      );
    });

    test('fails with detailed error on duplicate providers across modules',
        () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

class AppService {
  @inject
  AppService();
}

@module
class FirstModule {
  @provides
  AppService provideAppService() => AppService();
}

@module
class SecondModule {
  @provides
  AppService createAppService() => AppService();
}

@Component(modules: [FirstModule, SecondModule])
abstract class AppComponent {
  AppService appService();
}
''';

      final logs = <String>[];
      await _runBuilder(
        testSource,
        onLog: logs.add,
      );

      expect(
        logs,
        contains(
          contains(
            'Multiple providers found for type AppService: '
            'FirstModule.provideAppService, SecondModule.createAppService.',
          ),
        ),
      );
    });

    test('fails when a module has multiple providers for the same type',
        () async {
      const testSource = '''
import 'package:knife_annotations/knife_annotations.dart';

class AppService {
  @inject
  AppService();
}

@module
abstract class AppModule {
  @provides
  AppService provideFirst() => AppService();

  @provides
  AppService provideSecond() => AppService();
}

@Component(modules: [AppModule])
abstract class AppComponent {
  AppService appService();
}
''';

      final logs = <String>[];
      await _runBuilder(
        testSource,
        onLog: logs.add,
      );

      expect(
        logs,
        contains(
          contains(
            'Module AppModule has multiple providers for type AppService: '
            'provideFirst, provideSecond.',
          ),
        ),
      );
    });

    test('does not accept same-named annotations from another package',
        () async {
      const testSource = '''
import 'package:fake_annotations/fake_annotations.dart' as fake;
import 'package:knife_annotations/knife_annotations.dart';

class AppService {
  @fake.Inject()
  AppService();
}

@Component()
abstract class AppComponent {
  AppService appService();
}
''';

      final logs = <String>[];
      await _runBuilder(
        testSource,
        extraAssets: {
          'fake_annotations|lib/fake_annotations.dart': _fakeAnnotationsSource,
        },
        onLog: logs.add,
      );

      expect(
        logs,
        contains(
          contains('No provider found for type AppService'),
        ),
      );
    });
  });
}
