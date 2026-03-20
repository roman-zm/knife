import 'dart:developer';

import 'package:knife_annotations/knife_annotations.dart';

import 'example_service.dart';

class ExampleServiceImpl implements ExampleService {
  @inject
  const ExampleServiceImpl();

  @override
  String doSomething() {
    log('ExampleServiceImpl is doing something!');
    return 'Service Result';
  }
}
