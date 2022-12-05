import 'dart:developer';

import 'package:customermanager/services/customer/customerbook.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../../services/history/historybook.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final historyBook = Provider.of<HistoryBook>(context, listen: false);
    if(historyBook.customerId == null){
      log("cannot find customer info");
      return const Center(child: Text("cannot find customer info"),);
    }
    final customerBook = Provider.of<CustomerBook>(context, listen: false);
    final customer = customerBook.findCustomerById(customerId: historyBook.customerId!);
    if(customer == null){
      log("cannot find customer info in the local database");
      return const Center(child: Text("cannot find customer info"),);
    }
    return SingleChildScrollView(
      child: Column(children: [
        const Text("Name"),
        Text(customer.name ?? "no name"),
        const Text("Email Address"),
        Text(customer.email ?? "no email"),
        const Text("Phone Number"),
        Text(customer.phoneNumber ?? "no phone number"),
        const Text("register date"),
        Text(DateTime.fromMicrosecondsSinceEpoch(customer.registerDate.microsecondsSinceEpoch).toString()),
      ]),
    );
  }
}