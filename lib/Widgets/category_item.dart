import 'package:flutter/material.dart';
import 'package:new_expense/Widgets/new_item.dart';
import 'package:new_expense/data/dummy_items.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewItem(),
              ));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(groceryItems[index].name),
          leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[index].category.itemcolor),
          trailing: Text(groceryItems[index].quantity as String),
        ),
      ),
    );
  }
}
