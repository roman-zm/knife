import 'dart:developer';

import 'package:example/services/example_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

class ExampleServiceImpl2 implements ExampleService {
  const ExampleServiceImpl2();

  @inject
  const ExampleServiceImpl2.custom();

  @override
  String doSomething() {
    log('ExampleServiceImpl2 is doing something!');
    return 'Service Result';
  }
}
