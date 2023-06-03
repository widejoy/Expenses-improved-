import 'package:flutter/material.dart';
import 'package:new_expense/Widgets/new_item.dart';
import 'package:new_expense/data/dummy_items.dart';

import '../models/grocery_item.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  final List<GroceryItem> _groceryitems = [];

  @override
  Widget build(BuildContext context) {
    Widget elements = ListView.builder(
      itemCount: _groceryitems.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_groceryitems[index].name),
        leading: Container(
            width: 24,
            height: 24,
            color: _groceryitems[index].category.itemcolor),
        trailing: Text(
          _groceryitems[index].quantity.toString(),
        ),
      ),
    );
    if (_groceryitems.isEmpty) {
      setState(
        () {
          elements = const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'uhuh looks like ur list is empty',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 24,
                ),
                Text('try adding some')
              ],
            ),
          );
        },
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: () async {
                final newitem = await Navigator.of(context).push<GroceryItem>(
                  MaterialPageRoute(
                    builder: (context) => const NewItem(),
                  ),
                );
                if (newitem == null) {
                  return;
                } else {
                  setState(() {
                    _groceryitems.add(newitem);
                  });
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: elements);
  }
}
