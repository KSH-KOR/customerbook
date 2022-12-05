import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/routes.dart';
import '../../widgets/helpers.dart';
import '../../widgets/widget_decoration_frame.dart';
import '../homepage.dart';

class AllCustomerListView extends StatefulWidget {
  const AllCustomerListView({super.key});

  @override
  State<AllCustomerListView> createState() => _AllCustomerListViewState();
}

class _AllCustomerListViewState extends State<AllCustomerListView> {
  late final TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const AddVerticalSpace(height: 20),
          TextField(
            controller: textEditingController,
            onChanged: (value) {
              Provider.of<CustomerBook>(context, listen: false)
                  .setSearchCustomerList(searchWord: value);
            },
            decoration: InputDecoration(
              labelText: "Search name",
              prefixIcon: const Icon(Icons.search),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(width: 1, color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const AddVerticalSpace(height: 20),
          const Expanded(
            child: WidgetDecorationFrame(
              maximumHeight: 500,
              header: Text("all customer list"),
              child: CustomerCardList(
                isSearchMode: true,
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          Navigator.of(context).pushNamed(addNewCustomerRoute);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
