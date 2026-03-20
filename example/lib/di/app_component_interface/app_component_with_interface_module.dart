import 'package:example/di/app_component_interface/app_module_interface.dart';
import 'package:example/repository/example_repository.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component_with_interface_module.component.dart';

@Component(
  modules: [AppModuleInterface],
)
abstract class AppComponentWithInterfaceModule {
  ExampleRepository appRepository();

  factory AppComponentWithInterfaceModule() =
      KnifeAppComponentWithInterfaceModule;
}
