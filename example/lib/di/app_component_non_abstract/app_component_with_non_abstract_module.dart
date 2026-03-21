import 'package:example/di/app_component_non_abstract/non_abstract_module.dart';
import 'package:example/repository/app_repository.dart';
import 'package:example/services/app_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component_with_non_abstract_module.component.dart';

@Component(
  modules: [NonAbstractModule],
)
abstract class AppComponentWithNonAbstractModule {
  AppService appService();
  AppRepository appRepository();

  factory AppComponentWithNonAbstractModule() =
      KnifeAppComponentWithNonAbstractModule;
}
