import 'package:example/di/details_component/details_component.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  static const routeName = '/details';

  const DetailsPage({super.key, required this.detailsComponent});

  final DetailsComponent detailsComponent;

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as int;
    final item = detailsComponent.detailsRepository().getItem(id);

    return Scaffold(
      appBar: AppBar(title: Text('Item #${item.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${item.id}'),
            const SizedBox(height: 8),
            Text('Title: ${item.title}'),
          ],
        ),
      ),
    );
  }
}
