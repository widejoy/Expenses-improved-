import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_expense/data/categories.dart';
import 'package:new_expense/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname;
  int? _enteredquantity;
  var _enteredcategory = categories[Categories.vegetables];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 3 ||
                      value.trim().length > 50) {
                    return 'Must be between 3 and 50 characters long';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredname = newValue;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (newValue) =>
                          _enteredquantity = int.parse(newValue!),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _enteredcategory,
                      items: [
                        for (final i in categories.entries)
                          DropdownMenuItem(
                            value: i.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: i.value.itemcolor,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(i.value.item)
                              ],
                            ),
                          ),
                      ],
                      onChanged: (values) {
                        setState(() {
                          _enteredcategory = values;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formkey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        final url = Uri.http(
                            'flutter-shopping-a1103-default-rtdb.firebaseio.com',
                            'shopping-list.json');
                        http.post(
                          url,
                          headers: {'Content-type': 'application/json'},
                          body: json.encode({
                            'name':_enteredname,
                            'quantity':_enteredquantity,
                            'category':_enteredcategory?.item,
                            
                          }),
                        );
                        // Navigator.of(context).pop(
                        //   GroceryItem(
                        //     id: DateTime.now().toString(),
                        //     name: _enteredname,
                        //     category: _enteredcategory!,
                        //     quantity: _enteredquantity!,
                        //   ),
                        // );
                      }
                    },
                    child: const Text('Add Item'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
