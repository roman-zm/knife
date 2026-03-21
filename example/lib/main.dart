import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:flutter/material.dart';

import 'di/app_component/app_component.dart';
import 'ui/app.dart';

void main() {
  final appComponent = AppComponent();

  final repository = appComponent.appRepository();
  final data = repository.getData();
  log('AppRepository data: $data');

  runApp(
    App(appComponent: appComponent),
  );
}
