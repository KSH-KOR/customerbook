import 'package:customermanager/constants/routes.dart';
import 'package:customermanager/services/customer/model/customer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/history/historybook.dart';


class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final historyBook =  Provider.of<HistoryBook>(context, listen: false);
        if(historyBook.customerId != customer.customerId){
          historyBook.setOrSwitchCustomer(customerId: customer.customerId);
          historyBook.fetch(customerId: customer.customerId).then((value) async => await Navigator.of(context).pushNamed(customerDetailRoute, arguments: customer.customerId),);
        } else{
          await Navigator.of(context).pushNamed(customerDetailRoute, arguments: customer.customerId);
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 0,
        leading: customer.getProfileImage(height: 60, width: 60),
        title: Text(customer.name ?? "no name"),
        trailing: const Text("More"),
      
      ),
    );
  }
}