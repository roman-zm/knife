import 'package:example/repository/app/app_repository.dart';
import 'package:example/ui/list/list_page.dart';
import 'package:example/ui/screen/screen_page.dart';
import 'package:flutter/material.dart';

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AppRepository data: ${appRepository.getData()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(ScreenPage.routeName),
              child: const Text('Open Screen'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(ListPage.routeName),
              child: const Text('Open List'),
            ),
          ],
        ),
      ),
    );
  }
}
