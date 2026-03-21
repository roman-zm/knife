import 'package:example/repository/screen_repository.dart';
import 'package:example/repository/screen_repository_impl.dart';
import 'package:example/services/screen_service.dart';
import 'package:example/services/screen_service_impl.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'screen_module.module.dart';

@module
abstract class ScreenModule {
  ScreenModule._();
  factory ScreenModule() = KnifeScreenModule;

  @provides
  ScreenRepository provideScreenRepository(ScreenService screenService) =>
      ScreenRepositoryImpl(screenService);

  @binds
  ScreenService bindScreenService(ScreenServiceImpl impl);
}
