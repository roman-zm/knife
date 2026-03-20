import 'dart:developer';

import 'package:example/repository/example_repository.dart';
import 'package:example/services/example_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

class ExampleRepositoryImpl2 implements ExampleRepository {
  @inject
  const ExampleRepositoryImpl2(
    this._service,
  );

  final ExampleService _service;

  @override
  String getData() {
    log('ExampleRepositoryImpl2 is getting data using ExampleService!');
    return _service.doSomething();
  }
}
