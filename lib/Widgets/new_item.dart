import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_expense/data/categories.dart';
import 'package:new_expense/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _issending = false;

  void _saveItem() async {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _issending = true;
      });
      final url = Uri.https(
          'flutter-shopping-a1103-default-rtdb.firebaseio.com',
          'shopping-list.json');
      var encryptedname = encrypter.encrypt(_enteredName, iv: iv).base16;
      var encryptedquantity =
          encrypter.encrypt(_enteredQuantity.toString(), iv: iv).base16;
      var encryptercat =
          encrypter.encrypt(_selectedCategory.item, iv: iv).base16;

      final respose = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': encryptedname,
            'quantity': encryptedquantity,
            'category': encryptercat,
          },
        ),
      );
      final res = json.decode(respose.body);
      // ignore: use_build_context_synchronously
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
            id: res["name"],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
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
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ), // instead of TextField()
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.itemcolor,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.item),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _issending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _issending ? null : _saveItem,
                    child: _issending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
