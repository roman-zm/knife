import 'dart:developer';

import 'package:example/model/item.dart';
import 'package:example/repository/details/details_repository.dart';
import 'package:knife_annotations/knife_annotations.dart';

class DetailsRepositoryImpl implements DetailsRepository {
  @inject
  const DetailsRepositoryImpl(this.detailsService, this.itemService);

  final DetailsService detailsService;
  final ItemService itemService;

  @override
  Item getItem(int id) {
    log('DetailsRepositoryImpl: getItem($id)');
    return Item(id: id, title: 'Item #$id');
  }
}

class HttpClient {
  @inject
  const HttpClient();
}

class DetailsService {
  @inject
  const DetailsService(this.httpClient);

  final HttpClient httpClient;
}

class ItemService {
  @inject
  const ItemService(this.httpClient);

  final HttpClient httpClient;
}
