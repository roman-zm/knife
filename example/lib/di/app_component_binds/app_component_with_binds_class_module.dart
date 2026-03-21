import 'package:example/di/app_component_binds/app_module_binds_class.dart';
import 'package:example/repository/app/app_repository.dart';
import 'package:example/services/app/app_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component_with_binds_class_module.component.dart';

@Component(
  modules: [AppModuleBindsClass],
)
abstract class AppComponentWithBindsClassModule {
  AppRepository appRepository();
  AppService appService();

  factory AppComponentWithBindsClassModule() =
      KnifeAppComponentWithBindsClassModule;
}
