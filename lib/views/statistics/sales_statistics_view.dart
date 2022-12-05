import 'package:customermanager/services/customer/customerbook.dart';
import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/model/product.dart';
import 'package:customermanager/views/homepage.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../constants/routes.dart';
import '../../services/customer/model/customer.dart';
import '../../services/history/model/history.dart';
import '../../services/product/productbook.dart';
import '../../theme/appcolors.dart';
import '../../widgets/widget_decoration_frame.dart';

class SalesStatisticsView extends StatelessWidget {
  const SalesStatisticsView({super.key});

  List<Map<String, dynamic>> getAllStatistcsData(
      {required BuildContext context}) {
    final productBook = Provider.of<ProductBook>(context);
    final historyBook = Provider.of<HistoryBook>(context);
    final customerBook = Provider.of<CustomerBook>(context);

    final Map<String, int> salesByCustomerMap = {};
    final Map<String, int> salesByProductMap = {};
    final Map<String, double> profitByCustomerMap = {};
    final Map<String, double> profitByProductMap = {};

    for (final history in historyBook.historyBook) {
      if (history.selectedProductIds == null) continue;
      for (final productId in history.selectedProductIds!) {
        final product = productBook.findProductById(productId: productId);
        if (product == null) continue;
        final customer =
            customerBook.findCustomerById(customerId: history.customerId);
        if (customer == null) continue;
        final customerName = customer.name ?? "no name";
        final productName = product.name ?? "no name";
        salesByCustomerMap[customerName] =
            salesByCustomerMap[customerName] != null
                ? salesByCustomerMap[customerName]! + 1
                : 1;
        salesByProductMap[productName] = salesByProductMap[productName] != null
            ? salesByProductMap[productName]! + 1
            : 1;
        profitByCustomerMap[customerName] =
            profitByCustomerMap[customerName] != null
                ? profitByCustomerMap[customerName]! +
                    double.parse(product.price ?? "0")
                : double.parse(product.price ?? "0");
        profitByProductMap[productName] =
            profitByProductMap[productName] != null
                ? profitByProductMap[productName]! +
                    double.parse(product.price ?? "0")
                : double.parse(product.price ?? "0");
      }
    }
    return [
      salesByCustomerMap,
      salesByProductMap,
      profitByCustomerMap,
      profitByProductMap,
    ];
  }

  Widget _barSeriesCharts(
      {required List<Map<String, dynamic>> data, required String title}) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      // Chart title
      title: ChartTitle(
          text: title, textStyle: const TextStyle(color: Colors.black),
          ),
      // Enable legend
      legend: Legend(isVisible: true, ),

      // Enable tooltip
      tooltipBehavior: TooltipBehavior(enable: true),
      series: data
          .map(
            (map) => BarSeries<MapEntry<String, dynamic>, String>(
              dataSource: map.entries.toList(),
              xValueMapper: (MapEntry entry, _) => entry.key,
              yValueMapper: (MapEntry entry, _) => entry.value,
              animationDuration: 2000,
              name: 'Sales',
              borderColor: AppColors.primaryColor,
              // Enable data label
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = getAllStatistcsData(context: context);
    final titles = [
      "sales by customers",
      "sales by products",
      "profit by customer",
      "profit by product"
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text("Sales Statistics"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const AddVerticalSpace(height: 20),
                const ShowCustomerRecentPurchaseButtonList(),
                const AddVerticalSpace(height: 10),
                Column(
                  children: List.generate(
                    dataMap.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ChartDecorationBox(
                        child: _barSeriesCharts(
                            data: [dataMap[index]], title: titles[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowCustomerRecentPurchaseButtonList extends StatelessWidget {
  const ShowCustomerRecentPurchaseButtonList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerBook = Provider.of<CustomerBook>(context);
    return Container(
      color: Colors.white30,
      width: double.infinity,
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const ShowAllCustomerRecentPurchaseButton(),
            const SizedBox(width: 10),
            ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: customerBook.customerBook.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return ShowCustomerRecentPurchaseButton(
                  customer: customerBook.customerBook[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ShowAllCustomerRecentPurchaseButton extends StatelessWidget {
  const ShowAllCustomerRecentPurchaseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async =>
          await Provider.of<HistoryBook>(context, listen: false).fetchAll(),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Container(
          width: 100,
          color: AppColors.cardBackgroundColor,
          child: const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Show All Customer"))),
        ),
      ),
    );
  }
}

class ShowCustomerRecentPurchaseButton extends StatelessWidget {
  const ShowCustomerRecentPurchaseButton({
    Key? key,
    required this.customer,
  }) : super(key: key);

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => await Provider.of<HistoryBook>(context, listen: false)
          .fetch(customerId: customer.customerId),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Container(
          width: 100,
          color: AppColors.cardBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                child: customer.profileImageUrl != null
                    ? ClipOval(
                        clipBehavior: Clip.antiAlias,
                        //borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: Image.network(customer.profileImageUrl!))
                    : const Icon(Icons.portrait_rounded),
              ),
              Text(
                customer.name ?? "no name",
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PurchasesDatatable extends StatelessWidget {
  const PurchasesDatatable({
    Key? key, this.listLengthLimit,

  }) : super(key: key);

  final int? listLengthLimit;

  @override
  Widget build(BuildContext context) {
    final productBook = Provider.of<ProductBook>(context, listen: false);
    final historyBook = Provider.of<HistoryBook>(context);
    final customerBook = Provider.of<CustomerBook>(context, listen: false);
    

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: DataTable(
            horizontalMargin: 0,
            columns: const [
              DataColumn(label: Text("Customer")),
              DataColumn(label: Text("Product")),
              DataColumn(label: Text("Price")),
              DataColumn(label: Text("Date")),
            ],
            rows: List.generate(
              listLengthLimit == null ? historyBook.historyBook.length : listLengthLimit! < historyBook.historyBook.length ? listLengthLimit! : historyBook.historyBook.length, (index) {
              final history = historyBook.historyBook[index];
              final customer =
                  customerBook.findCustomerById(customerId: history.customerId);
              final productIds = history.selectedProductIds;
              final Product? product;
              final length = productIds == null ? 0 : productIds.length;
              if (length == 0) {
                product = null;
              } else {
                product = productBook.findProductById(
                    productId: history.selectedProductIds!.first);
              }
              return DataRow(cells: [
                DataCell(Text(customer?.name ?? "no name")),
                DataCell(FittedBox(
                  child: Row(
                    children: [
                      Text(product?.name ?? "no name"),
                      Visibility(
                        visible: length >= 2,
                        child: Text(" +${length - 1}"),
                      ),
                    ],
                  ),
                )),
                DataCell(Text(product?.price ?? "0")),
                DataCell(FittedBox(
                    child: Text(DateFormat('yyyy-MM-dd – kk:mm').format(
                        DateTime.fromMicrosecondsSinceEpoch(
                            history.date.microsecondsSinceEpoch))))),
              ]);
            }),
          ),
    );
  }
}

class ChartDecorationBox extends StatelessWidget {
  const ChartDecorationBox({
    required this.child,
    Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: DecoratedBox(
        decoration:  const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          color: AppColors.cardBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}
