import 'dart:developer';

import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/customer/customerbook.dart';
import '../../../services/customer/model/customer.dart';
import '../../../services/product/model/product.dart';
import '../../../theme/appcolors.dart';

class AddNewHistoryView extends StatelessWidget {
  const AddNewHistoryView({super.key});

  final int noteMaxLines = 6;

  @override
  Widget build(BuildContext context) {
    final noteTextEditingController = TextEditingController();
    late final String arg;
    try {
      arg = ModalRoute.of(context)!.settings.arguments as String;
    } catch (e) {
      log("add new history page: got wrong argument. error msg:$e");
      Navigator.of(context).pop();
    }
    final Customer? customer = Provider.of<CustomerBook>(context, listen: false)
        .findCustomerById(customerId: arg);
    if (customer == null) {
      log("customer detail page: customer info missing");
      Navigator.of(context).pop();
    }
    final historyBook = Provider.of<HistoryBook>(context, listen: false);
    final productBook = Provider.of<ProductBook>(
      context,
    );
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const AddVerticalSpace(height: 100),
                DropdownSelector(dropdownItems: productBook.productBook),
                const AddVerticalSpace(height: 20),
                SizedBox(
                  height: noteMaxLines*24,
                  child: TextField(
                    controller: noteTextEditingController,
                    maxLines: noteMaxLines,
                    decoration: InputDecoration(
                      
                      labelText: "Note",
                      prefixIcon: const Icon(Icons.person),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1, color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: OutlinedButton(
          child: const Text("Add New History"),
          onPressed: () async {
            Navigator.of(context).pop();
            for(final productId in  SelectedValueContainer().selectedItemsId()){
              productBook.increaseSalesCount(productId: productId);
            }
            await historyBook.createOrEidtHistoryToCloud(
              customerId: customer!.customerId,
              description: noteTextEditingController.text.isNotEmpty
                  ? noteTextEditingController.text
                  : null,
              selectedProductIds: SelectedValueContainer().selectedItemsId(),
            );
            SelectedValueContainer().selectedProducts = [];
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class DropdownSelector extends StatelessWidget {
  const DropdownSelector({super.key, required List<Product> dropdownItems})
      : _dropdownItems = dropdownItems;

  final List<Product> _dropdownItems;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Product>.multiSelection(
      items: _dropdownItems,
      itemAsString: (Product product) => product.name ?? "no name",
      popupProps: PopupPropsMultiSelection.modalBottomSheet(
        disabledItemFn: (item) => !(item.isAvailable ?? false),
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[100]),
            child: Row(
              children: [
                Text(
                  (item.isAvailable ?? false) 
                    ? "${item.name}" 
                    : "${item.name} [unavailable]",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.indigo),
                ),
                const Padding(padding: EdgeInsets.only(left: 8)),
                isSelected ? const Icon(Icons.check_box_outlined) : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(labelText: "Select Product"),
      ),
      onChanged: (value) {
        SelectedValueContainer().selectedProducts = value;
      },
    );
  }
}


class SelectedValueContainer{
  static final SelectedValueContainer _singleton = SelectedValueContainer._internal();

  factory SelectedValueContainer() {
    return _singleton;
  }

  SelectedValueContainer._internal();

  bool? available;
  
  List<Product> selectedProducts = [];
  List<String> selectedItemsId() => selectedProducts.map((e) => e.productId,).toList();

}