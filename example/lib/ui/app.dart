import 'package:example/repository/app_repository.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  final AppRepository repository;
  const App({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('DI Demo')),
        body: Center(child: Text(repository.getData())),
      ),
    );
  }
}
