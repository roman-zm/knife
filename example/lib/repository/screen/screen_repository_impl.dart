import 'dart:developer';

import 'package:example/repository/screen/screen_repository.dart';
import 'package:example/services/screen/screen_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

class ScreenRepositoryImpl implements ScreenRepository {
  @inject
  const ScreenRepositoryImpl(this._service);

  final ScreenService _service;

  @override
  String getData() {
    log('ScreenRepositoryImpl is getting data using ScreenService!');
    return '${_service.doSomething()} from ScreenRepositoryImpl';
  }
}
