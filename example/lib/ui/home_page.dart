import 'package:example/repository/app/app_repository.dart';
import 'package:flutter/material.dart';

import 'screen_page.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/';

  const HomePage({super.key, required this.appRepository});

  final AppRepository appRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DI Demo')),
      body: Center(
        child: Column(
          children: [
            Text('AppRepository data: ${appRepository.getData()}'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(ScreenPage.routeName);
              },
              child: const Text('Open Screen Component Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
