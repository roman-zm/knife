import 'dart:developer';

import 'package:knife_annotations/knife_annotations.dart';

import 'example_repository.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  @inject
  const ExampleRepositoryImpl();

  @override
  String getData() {
    log('ExampleRepositoryImpl is getting data!');
    return 'Repository Data';
  }
}
