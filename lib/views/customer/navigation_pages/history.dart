import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/widgets/available_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/dialogs/delete_dialog.dart';

import 'package:intl/intl.dart';

class CustomerHistoryPage extends StatelessWidget {
  const CustomerHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final historyBook = Provider.of<HistoryBook>(context);
    final productBook = Provider.of<ProductBook>(context);
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: historyBook.historyBook.length,
      itemBuilder: (context, index) {
        return InkWell(
          onLongPress: () {
            showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              final list = historyBook.historyBook[index].selectedProductIds;
              return SizedBox(
                height: 200,
                child: Center(
                  child: Visibility(
                    visible: list != null,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list!.length,
                      itemBuilder: (context, index) {
                        final product = productBook.findProductById(productId: list[index]);
                        if(product == null){
                          return const Text("no product found by id");
                        }
                        return ListTile(
                          leading: Text(product.name ?? "no product name"),
                          title: Text(product.description ?? "no description"),
                          subtitle: Text(product.price ?? "no price"),
                          trailing: Text(DateTime.fromMicrosecondsSinceEpoch(product.lastModifiedDate.microsecondsSinceEpoch).toString()),
                        );
                    },),
                  ),
                ),
              );
            },
          );
          },
          child: Card(
            child: ListTile(
              leading: Text(DateFormat("yyyy-MM-dd").format(
                  DateTime.fromMicrosecondsSinceEpoch(
                      historyBook.historyBook[index].date.microsecondsSinceEpoch))),
              title: Text(
                  historyBook.historyBook[index].description ?? "no description"),
              trailing: IconButton(
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(
                      context, 'Are you sure you want to delete this history?');
                  if (shouldDelete) {
                    await historyBook.removeHistoryToCloud(
                        historyId: historyBook.historyBook[index].historyId);
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ),
        );
      },
    );
  }
}
