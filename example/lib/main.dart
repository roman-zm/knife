import 'package:flutter/material.dart';

import 'di/app_component/app_component.dart';
import 'ui/app.dart';

void main() {
  final appComponent = AppComponent();
  final repository = appComponent.appRepository();

  runApp(App(repository: repository));
}
