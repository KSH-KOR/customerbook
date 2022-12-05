import 'package:customermanager/constants/routes.dart';
import 'package:customermanager/services/history/historybook.dart';
import 'package:customermanager/services/product/productbook.dart';
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
          onTap: () {
            showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              final list = historyBook.historyBook[index].selectedProductIds;
              final date = historyBook.historyBook[index].date;
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
                        return InkWell(
                          onLongPress: () {
                            Navigator.of(context).pushNamed(productDetailRoute, arguments: product.productId);
                          },
                          child: ListTile(
                            leading: Text(product.name ?? "no product name"),
                            title: Text(product.description ?? "no description", maxLines: 1, overflow: TextOverflow.ellipsis,),
                            subtitle: Text("price: ${product.price ?? "no price"}"),
                            trailing: Text(DateFormat("yyyy-MM-dd HH:mm").format(
                                          DateTime.fromMicrosecondsSinceEpoch(
                                              date.microsecondsSinceEpoch))),
                          ),
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
