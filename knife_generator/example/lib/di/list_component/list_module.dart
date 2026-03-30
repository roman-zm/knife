import 'package:example/repository/list/list_repository.dart';
import 'package:example/repository/list/list_repository_impl.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'list_module.module.dart';

@module
abstract class ListModule {
  ListModule._();
  factory ListModule() = KnifeListModule;

  @binds
  ListRepository bindListRepository(ListRepositoryImpl impl);
}
