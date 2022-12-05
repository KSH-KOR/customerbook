
import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/views/progress_indicate_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/routes.dart';
import '../services/auth/auth_provider.dart';
import 'homepage.dart';
import 'loginview.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerBook = Provider.of<CustomerBook>(context, listen: false);
    final productBook = Provider.of<ProductBook>(context, listen: false);
    return StreamBuilder(
      stream: authProvider.getAuthStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          if (customerBook.userId != snapshot.data!.uid) {
            customerBook.setOrSwitchUser(userId: snapshot.data!.uid);
            productBook.setOrSwitchUser(userId: snapshot.data!.uid);
          }
          return FutureBuilder(
            future: Future.wait([customerBook.fetch(), productBook.fetch()]),
            builder: (context, snapshot) {
              switch(snapshot.connectionState){
                case ConnectionState.done:
                  return const Homepage();
                default:
                  return const ProgressIndicateView(message: "loading..");
              }
            },
          );
        } else if (snapshot.hasError) {
          customerBook.customerBook.clear();
          productBook.productBook.clear();
          Provider.of<HistoryBook>(context, listen: false).historyBook.clear();
          return const Center(
            child: Text("Something went Wrong!"),
          );
        } else {
          customerBook.customerBook.clear();
          productBook.productBook.clear();
          Provider.of<HistoryBook>(context, listen: false).historyBook.clear();
          return const LoginView();
        }
      },
    );
  }
}
