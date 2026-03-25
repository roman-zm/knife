import 'package:example/model/item.dart';

abstract class DetailsRepository {
  Item getItem(int id);
}
