import 'package:example/di/app_component/app_module.dart';
import 'package:example/di/screen_component/screen_component.dart';
import 'package:example/repository/app/app_repository.dart';
import 'package:example/services/app/app_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component.component.dart';

@Component(
  modules: [AppModule],
)
abstract class AppComponent {
  AppService appService();
  AppRepository appRepository();

  ScreenComponent screenComponent();

  factory AppComponent() = KnifeAppComponent;
}
