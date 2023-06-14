import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_expense/Widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'package:new_expense/data/categories.dart';

import '../models/grocery_item.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  List<GroceryItem> _groceryitems = [];
  var isloading = true;
  void _loaditems() async {
    final url = Uri.https('flutter-shopping-a1103-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> listdata = json.decode(response.body);
    final List<GroceryItem> loadeditems = [];
    for (final i in listdata.entries) {
      loadeditems.add(
        GroceryItem(
            id: i.key,
            name: i.value["name"],
            quantity: i.value["quantity"],
            category: categories.entries
                .firstWhere(
                  (element) => element.value.item == i.value['category'],
                )
                .value),
      );
    }
    setState(() {
      _groceryitems = loadeditems;
      isloading = false;
    });
  }

  void _removeitem(GroceryItem i) {
    final url = Uri.https('flutter-shopping-a1103-default-rtdb.firebaseio.com',
        'shopping-list/${i.id}.json');
    http.delete(url);
    setState(() {
      _groceryitems.remove(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget elements = ListView.builder(
      itemCount: _groceryitems.length,
      itemBuilder: (context, index) => Dismissible(
        background: Container(
          color: const Color.fromARGB(255, 234, 0, 0),
        ),
        key: ValueKey(_groceryitems[index].id),
        child: ListTile(
          onTap: () async {
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
            _groceryitems.remove(_groceryitems[index]);
            final url = Uri.https(
                'flutter-shopping-a1103-default-rtdb.firebaseio.com',
                'shopping-list/${_groceryitems[index].id}.json');
            http.delete(url);
          },
          title: Text(_groceryitems[index].name),
          leading: Container(
              width: 24,
              height: 24,
              color: _groceryitems[index].category.itemcolor),
          trailing: Text(
            _groceryitems[index].quantity.toString(),
          ),
        ),
        onDismissed: (direction) => _removeitem(_groceryitems[index]),
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
    if (isloading) {
      elements = const Center(
        child: CircularProgressIndicator(
            backgroundColor: Colors.blue, color: Colors.blueGrey),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Your Groceries'),
              const SizedBox(
                width: 38,
              ),
              DropdownButton(
                items: [
                  DropdownMenuItem(
                    child: const Text("All"),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  for (final i in categories.entries)
                    DropdownMenuItem(
                      onTap: () {
                        setState(() {
                          _groceryitems = _groceryitems
                              .where((element) =>
                                  element.category.item == i.value.item)
                              .toList();
                        });
                      },
                      value: i.value.item,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: i.value.itemcolor,
                          ),
                          const SizedBox(width: 6),
                          Text(i.value.item),
                        ],
                      ),
                    )
                ],
                onChanged: (value) {},
              ),
            ],
          ),
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
