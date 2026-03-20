import 'package:example/di/app_component_binds/app_module_binds_class.dart';
import 'package:example/repository/example_repository.dart';
import 'package:example/services/example_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component_with_binds_class_module.component.dart';

@Component(
  modules: [AppModuleBindsClass],
)
abstract class AppComponentWithBindsClassModule {
  ExampleRepository appRepository();
  ExampleService appService();

  factory AppComponentWithBindsClassModule() =
      KnifeAppComponentWithBindsClassModule;
}
