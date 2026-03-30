import 'package:example/di/list_component/list_module.dart';
import 'package:example/repository/list/list_repository.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'list_component.component.dart';

@Component(
  modules: [ListModule],
)
abstract class ListComponent {
  ListRepository listRepository();

  @inject
  factory ListComponent() = KnifeListComponent;
}
