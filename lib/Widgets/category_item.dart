import 'package:flutter/material.dart';
import 'package:new_expense/data/dummy_items.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(groceryItems[index].name),
          leading: Container(
            width: 24,height: 24,color: groceryItems[index].category.itemcolor
          ),
          trailing: Text(groceryItems[index].quantity as String),
        ),
      ),
    );
  }
}
