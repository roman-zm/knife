import 'package:example/repository/example_repository.dart';
import 'package:example/repository/example_repository_impl2.dart';
import 'package:example/services/example_service.dart';
import 'package:example/services/example_service_impl2.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module_binds_class.module.dart';

@module
abstract class AppModuleBindsClass {
  @binds
  ExampleRepository bindrovideAppRepository(ExampleRepositoryImpl2 impl);

  @binds
  ExampleService bindAppService(ExampleServiceImpl2 impl);

  factory AppModuleBindsClass() = KnifeAppModuleBindsClass;
}
