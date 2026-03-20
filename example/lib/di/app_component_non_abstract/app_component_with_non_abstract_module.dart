import 'package:example/di/app_component_non_abstract/non_abstract_module.dart';
import 'package:example/repository/example_repository.dart';
import 'package:example/services/example_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component_with_non_abstract_module.component.dart';

@Component(
  modules: [NonAbstractModule],
)
abstract class AppComponentWithNonAbstractModule {
  ExampleService appService();
  ExampleRepository appRepository();

  factory AppComponentWithNonAbstractModule() =
      KnifeAppComponentWithNonAbstractModule;
}
