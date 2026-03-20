import 'package:example/di/app_component/app_module.dart';
import 'package:example/repository/example_repository.dart';
import 'package:example/services/example_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'app_component.component.dart';

@Component(
  modules: [AppModule],
)
abstract class AppComponent {
  ExampleService appService();
  ExampleRepository appRepository();

  factory AppComponent() = KnifeAppComponent;
}
