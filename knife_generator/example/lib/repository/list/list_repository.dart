import 'package:example/model/item.dart';

abstract class ListRepository {
  List<Item> getItems();
}
