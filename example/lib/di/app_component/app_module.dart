import 'package:example/repository/example_repository.dart';
import 'package:example/repository/example_repository_impl2.dart';
import 'package:example/services/example_service.dart';
import 'package:example/services/example_service_impl2.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module.module.dart';

@module
abstract class AppModule {
  AppModule._();
  factory AppModule() = KnifeAppModule;

  @provides
  ExampleRepository provideAppRepository(ExampleService appService) =>
      ExampleRepositoryImpl2(appService);

  @binds
  ExampleService bindAppService(ExampleServiceImpl2 impl);
}
