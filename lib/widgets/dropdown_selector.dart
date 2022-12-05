import '../services/customer/customerbook.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../services/customer/constant/enum.dart';

class DropDownButtons extends StatelessWidget {
  const DropDownButtons({super.key, required this.dropdownList});

  final List<CustomerDisplayOrder> dropdownList;

  @override
  Widget build(BuildContext context) {
    final customerBook = Provider.of<CustomerBook>(context, listen: true);
    return DropdownButton<CustomerDisplayOrder>(
      value: customerBook.dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (CustomerDisplayOrder? value) {
        // This is called when the user selects an item.
        customerBook.dropdownValue = value!;
      },
      items: dropdownList.map<DropdownMenuItem<CustomerDisplayOrder>>((CustomerDisplayOrder value) {
        return DropdownMenuItem<CustomerDisplayOrder>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}