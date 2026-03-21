import 'dart:developer';

import 'package:example/services/app_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

class AppServiceImpl2 implements AppService {
  const AppServiceImpl2();

  @inject
  const AppServiceImpl2.custom();

  @override
  String doSomething() {
    log('AppServiceImpl2 is doing something!');
    return 'Service Result';
  }
}
