import 'package:example/di/app_component/app_component.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'screen_page.dart';

class App extends StatelessWidget {
  final AppComponent appComponent;

  const App({
    super.key,
    required this.appComponent,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (_) =>
            HomePage(appRepository: appComponent.appRepository()),
        ScreenPage.routeName: (_) =>
            ScreenPage(screenComponent: appComponent.screenComponent()),
      },
    );
  }
}
