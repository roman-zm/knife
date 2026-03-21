import 'package:example/di/screen_component/screen_component.dart';
import 'package:flutter/material.dart';

class ScreenPage extends StatelessWidget {
  static const routeName = '/screen';

  const ScreenPage({super.key, required this.screenComponent});

  final ScreenComponent screenComponent;

  @override
  Widget build(BuildContext context) {
    final serviceResult = screenComponent.screenService().doSomething();
    final repositoryResult = screenComponent.screenRepository().getData();

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Component Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ScreenService result:'),
            const SizedBox(height: 8),
            Text(serviceResult),
            const SizedBox(height: 24),
            const Text('ScreenRepository result:'),
            const SizedBox(height: 8),
            Text(repositoryResult),
          ],
        ),
      ),
    );
  }
}
