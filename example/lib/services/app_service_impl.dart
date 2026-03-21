import 'dart:developer';

import 'package:knife_annotations/knife_annotations.dart';

import 'app_service.dart';

class AppServiceImpl implements AppService {
  @inject
  const AppServiceImpl();

  @override
  String doSomething() {
    log('AppServiceImpl is doing something!');
    return 'Service Result';
  }
}
