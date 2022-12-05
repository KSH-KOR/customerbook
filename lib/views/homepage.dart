import 'dart:developer';

import 'package:customermanager/constants/routes.dart';
import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/theme/appcolors.dart';
import 'package:customermanager/views/statistics/sales_statistics_view.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_provider.dart';
import '../widgets/widget_decoration_frame.dart';
import 'customer/customer_card.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Customer Overview"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(addNewCustomerRoute);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Text(''),
            ),
            ListTile(
              title: const Text('log out'),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).signout();
              },
            ),
            ListTile(
              title: const Text('manage products'),
              onTap: () async {
                await Navigator.of(context).pushNamed(productListRoute);
              },
            ),
            ListTile(
              title: const Text('statistics'),
              onTap: () async {
                Provider.of<HistoryBook>(context, listen: false)
                    .fetchAll()
                    .then((value) async => await Navigator.of(context)
                        .pushNamed(productSalesRoute));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const AddVerticalSpace(height: 20),
              const ShowCustomerRecentPurchaseButtonList(),
              const AddVerticalSpace(height: 20),
              WidgetDecorationFrame(
                maximumHeight: 300,
                header: const Text("Recent Purchase"),
                child: const PurchasesDatatable(
                  listLengthLimit: 5,
                ),
                moreCallBackAction: () async {
                  Provider.of<HistoryBook>(context, listen: false)
                      .fetchAll()
                      .then(
                        (_) async => await Navigator.of(context)
                            .pushNamed(allHistoryRoute),
                      );
                },
              ),
              const AddVerticalSpace(height: 20),
              WidgetDecorationFrame(
                maximumHeight: 500,
                header: const Text("customer list"),
                child: const CustomerCardList(),
                moreCallBackAction: () async {
                  Provider.of<CustomerBook>(context, listen: false).setSearchCustomerList(searchWord: '');
                  await Navigator.of(context).pushNamed(customerListRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerCardList extends StatelessWidget {
  const CustomerCardList({
    Key? key,
    this.isSearchMode = false,
  }) : super(key: key);

  final bool isSearchMode;

  @override
  Widget build(BuildContext context) {
    final customerBook = Provider.of<CustomerBook>(context);
    return customerBook.customerBook.isEmpty
        ? Center(
            child: TextButton(
              child: const Text("add customer"),
              onPressed: () {
                Navigator.of(context).pushNamed(addNewCustomerRoute);
              },
            ),
          )
        : ListView.separated(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: isSearchMode
                ? customerBook.searchedCustomerList.length
                : customerBook.customerBook.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return CustomerCard(
                  customer: isSearchMode
                      ? customerBook.searchedCustomerList[index]
                      : customerBook.customerBook[index]);
            },
          );
  }
}
