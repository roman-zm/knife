import 'package:example/di/screen_component/screen_module.dart';
import 'package:example/repository/screen/screen_repository.dart';
import 'package:example/services/screen/screen_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'screen_component.component.dart';

@Component(
  modules: [ScreenModule],
)
abstract class ScreenComponent {
  ScreenService screenService();
  ScreenRepository screenRepository();

  factory ScreenComponent() = KnifeScreenComponent;
}
