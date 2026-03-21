import 'package:example/repository/app_repository.dart';
import 'package:example/repository/app_repository_impl.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module_interface.module.dart';

@module
abstract interface class AppModuleInterface {
  @binds
  AppRepository bindAppRepository(AppRepositoryImpl impl);

  factory AppModuleInterface() = KnifeAppModuleInterface;
}
