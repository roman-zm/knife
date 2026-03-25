import 'package:example/di/app_component/app_component.dart';
import 'package:flutter/material.dart';

import 'details/details_page.dart';
import 'home/home_page.dart';
import 'list/list_page.dart';
import 'screen/screen_page.dart';

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
        ListPage.routeName: (_) =>
            ListPage(listComponent: appComponent.listComponent()),
        DetailsPage.routeName: (_) =>
            DetailsPage(detailsComponent: appComponent.detailsComponent()),
      },
    );
  }
}
