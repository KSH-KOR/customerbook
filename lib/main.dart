import 'package:customermanager/services/auth/auth_provider.dart';
import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/services/file/file_cloud_storage.dart';
import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/views/customer/add_new_customer_view.dart';
import 'package:customermanager/views/customer/all_customer_list_view.dart';
import 'package:customermanager/views/customer/customer_detail_view.dart';
import 'package:customermanager/views/customer/navigation_pages/add_new_history_view.dart';
import 'package:customermanager/views/homepage.dart';
import 'package:customermanager/views/product/add_new_product_view.dart';
import 'package:customermanager/views/product/product_list_view.dart';
import 'package:customermanager/views/statistics/all_history_view.dart';
import 'package:provider/provider.dart';

import 'constants/routes.dart';
import 'views/auth_states_changes.dart';
import 'views/loginview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'views/product/product_detail_view.dart';
import 'views/statistics/sales_statistics_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
                  create: (BuildContext context) => CustomerBook()), 
      ChangeNotifierProvider(
                  create: (BuildContext context) => AuthProvider()), 
      ChangeNotifierProvider(
                  create: (BuildContext context) => FileCloudStorage()), 
      ChangeNotifierProvider(
                  create: (BuildContext context) => HistoryBook()), 
      ChangeNotifierProvider(
                  create: (BuildContext context) => ProductBook()), 
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: authStateChangeRoute,
      routes: {
        // forgotPasswordRoute: (BuildContext context) => const DetailView(),
        authStateChangeRoute: (BuildContext context) => const AuthStateChanges(),
        loginRoute: (BuildContext context) => const LoginView(),
        addNewCustomerRoute:(context) => const AddNewCustomerView(),
        customerListRoute:(context) => const AllCustomerListView(),
        customerDetailRoute:(context) => const CustomerDetailView(),
        addNewHistoryRoute:(context) => const AddNewHistoryView(),
        productListRoute:(context) => const ProductListView(),
        addNewProductRoute:(context) => const AddNewProductView(),
        productDetailRoute:(context) => const ProductDetailView(),
        homepageRoute:(context) => const Homepage(),
        productSalesRoute:(context) => const SalesStatisticsView(),
         allHistoryRoute:(context) => const AllHistoryView(),
        // addNewCustomerRoute: (BuildContext context) => AddNewProductView(),
        // addNewHistoryRoute: (BuildContext context) => AddNewProductView(),
        // addNewPreferenceRoute: (BuildContext context) => AddNewProductView(),
        // editCustomerInfoRoute: (BuildContext context) => AddNewProductView(),
        // editHistoryInfoRoute: (BuildContext context) => AddNewProductView(),
        // editPreferenceInfoRoute: (BuildContext context) => AddNewProductView(),
      },
    ),
  ));
}

