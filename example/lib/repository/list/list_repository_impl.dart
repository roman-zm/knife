import 'dart:developer';

import 'package:example/model/item.dart';
import 'package:example/repository/list/list_repository.dart';
import 'package:knife_annotations/knife_annotations.dart';

class ListRepositoryImpl implements ListRepository {
  @inject
  const ListRepositoryImpl();

  @override
  List<Item> getItems() {
    log('ListRepositoryImpl: getItems');
    return const [
      Item(id: 1, title: 'Item One'),
      Item(id: 2, title: 'Item Two'),
      Item(id: 3, title: 'Item Three'),
    ];
  }
}
