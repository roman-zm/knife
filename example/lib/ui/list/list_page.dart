import 'package:example/di/list_component/list_component.dart';
import 'package:example/ui/details/details_page.dart';
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  static const routeName = '/list';

  const ListPage({super.key, required this.listComponent});

  final ListComponent listComponent;

  @override
  Widget build(BuildContext context) {
    final items = listComponent.listRepository().getItems();

    return Scaffold(
      appBar: AppBar(title: const Text('List')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed(
              DetailsPage.routeName,
              arguments: item.id,
            ),
          );
        },
      ),
    );
  }
}
