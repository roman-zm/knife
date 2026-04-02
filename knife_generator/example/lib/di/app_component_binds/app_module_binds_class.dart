import 'package:example/repository/app/app_repository.dart';
import 'package:example/repository/app/app_repository_impl2.dart';
import 'package:example/services/app/app_service.dart';
import 'package:example/services/app/app_service_impl2.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module_binds_class.module.dart';

@module
abstract class AppModuleBindsClass {
  @binds
  @cached
  AppRepository bindrovideAppRepository(AppRepositoryImpl2 impl);

  @binds
  @cached
  AppService bindAppService(AppServiceImpl2 impl);

  factory AppModuleBindsClass() = KnifeAppModuleBindsClass;
}
