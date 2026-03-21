import 'package:example/di/app_component/app_component.dart';
import 'package:example/di/screen_component/screen_component.dart';
import 'package:flutter/material.dart';

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
      routes: {
        ScreenPage.routeName: (_) =>
            ScreenPage(screenComponent: ScreenComponent()),
      },
      home: Scaffold(
        appBar: AppBar(title: const Text('DI Demo')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ScreenPage.routeName);
                },
                child: const Text('Open Screen Component Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
