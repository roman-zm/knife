import 'dart:developer';

import 'package:example/services/screen/screen_service.dart';
import 'package:knife_annotations/knife_annotations.dart';

class ScreenServiceImpl implements ScreenService {
  @inject
  const ScreenServiceImpl();

  @override
  String doSomething() {
    log('ScreenServiceImpl is doing something!');
    return 'Screen Service Result';
  }
}
