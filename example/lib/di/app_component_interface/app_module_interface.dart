import 'package:example/repository/example_repository.dart';
import 'package:example/repository/example_repository_impl.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'app_module_interface.module.dart';

@module
abstract interface class AppModuleInterface {
  @binds
  ExampleRepository bindAppRepository(ExampleRepositoryImpl impl);

  factory AppModuleInterface() = KnifeAppModuleInterface;
}
