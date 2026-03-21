import 'dart:developer';

import 'package:example/repository/app/app_repository.dart';
import 'package:example/services/app/app_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

class AppRepositoryImpl2 implements AppRepository {
  @inject
  const AppRepositoryImpl2(
    this._service,
  );

  final AppService _service;

  @override
  String getData() {
    log('AppRepositoryImpl2 is getting data using AppService!');
    return _service.doSomething();
  }
}
