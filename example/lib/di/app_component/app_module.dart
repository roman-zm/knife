import 'package:example/repository/app_repository.dart';
import 'package:example/repository/app_repository_impl2.dart';
import 'package:example/services/app_service.dart';
import 'package:example/services/app_service_impl2.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module.module.dart';

@module
abstract class AppModule {
  AppModule._();
  factory AppModule() = KnifeAppModule;

  @provides
  AppRepository provideAppRepository(AppService appService) =>
      AppRepositoryImpl2(appService);

  @binds
  AppService bindAppService(AppServiceImpl2 impl);
}
