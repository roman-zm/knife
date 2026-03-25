import 'package:example/di/details_component/details_module.dart';
import 'package:example/repository/details/details_repository.dart';
import 'package:knife_annotations/knife_annotations.dart';

import 'details_component.component.dart';

@Component(
  modules: [DetailsModule],
)
abstract class DetailsComponent {
  DetailsRepository detailsRepository();

  @inject
  factory DetailsComponent() = KnifeDetailsComponent;
}
