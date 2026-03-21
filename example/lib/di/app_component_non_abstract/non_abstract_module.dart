import 'package:example/repository/app/app_repository.dart';
import 'package:example/repository/app/app_repository_impl2.dart';
import 'package:example/services/app/app_service.dart';
import 'package:example/services/app/app_service_impl2.dart';
import 'package:knife_annotations/knife_annotations.dart';

@module
class NonAbstractModule {
  @provides
  AppRepository provideAppRepository(AppService appService) =>
      AppRepositoryImpl2(appService);

  @provides
  AppService provideAppService() => const AppServiceImpl2();
}
