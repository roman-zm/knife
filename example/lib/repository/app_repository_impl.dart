import 'dart:developer';

import 'package:knife_annotations/knife_annotations.dart';

import 'app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  @inject
  const AppRepositoryImpl();

  @override
  String getData() {
    log('AppRepositoryImpl is getting data!');
    return 'Repository Data';
  }
}
