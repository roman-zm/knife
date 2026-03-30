import 'package:example/repository/details/details_repository.dart';
import 'package:example/repository/details/details_repository_impl.dart';
import 'package:knife_annotations/knife_annotations.dart';

part 'details_module.module.dart';

@module
abstract class DetailsModule {
  DetailsModule._();
  factory DetailsModule() = KnifeDetailsModule;

  @binds
  DetailsRepository bindDetailsRepository(DetailsRepositoryImpl impl);
}
