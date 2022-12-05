import 'package:customermanager/constants/routes.dart';
import 'package:customermanager/services/file/file_cloud_storage.dart';
import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/widgets/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/file/const/cloud_directory_path.dart';
import '../../services/product/model/product.dart';
import '../../widgets/widget_decoration_frame.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final productBook = Provider.of<ProductBook>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(addNewProductRoute);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WidgetDecorationFrame(
              maximumHeight: 150,
              header: Text("Recent Added Product"),
              child: RecentAddedProductList(),
            ),
            const AddVerticalSpace(height: 20),
            productBook.productBook.isEmpty
                      ? AddSomethingListIsEmpty(msg: "Click here to add Products", callBack: () async => await Navigator.of(context).pushNamed(addNewProductRoute),)
                : const WidgetDecorationFrame(
                  maximumHeight: 500,
                   header: Text("All product list"),
                    child: ProductList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class RecentAddedProductList extends StatelessWidget {
  const RecentAddedProductList({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final productBook = Provider.of<ProductBook>(context);
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: productBook.productBook.length,
        itemBuilder: (context, index) {
          final product = productBook.productBook[index];
          return InkWell(
            child: SizedBox(
              height: 80,
              width: 80,
              child: Card(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      top: 0,
                      left: 0,
                      right: 0,
                      child: product.getFirstProductImage(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text(product.name ?? "no name",),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              Navigator.of(context).pushNamed(productDetailRoute, arguments: product.productId);
            },
          );
        },
      ),
    );
  }
}

class AddSomethingListIsEmpty extends StatelessWidget {
  const AddSomethingListIsEmpty({
    Key? key, required this.msg, required this.callBack,
  }) : super(key: key);

  final String msg;
  final VoidCallback callBack;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
          onPressed: callBack,
          child: Text(msg),
        ),
      );
  }
}

class ProductListCard extends StatelessWidget {
  const ProductListCard({
    Key? key, required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final productBook = Provider.of<ProductBook>(context);
    final fileCloudStorage =
        Provider.of<FileCloudStorage>(context, listen: false);
    return ListTile(
        title: Text(product.name ?? "no name"),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            productBook.deleteProductInCloud(productId: product.productId);
            if(product.productImageCloudPath != null){
              await fileCloudStorage.deleteFileOnCloud(
                fileName: product.productId,
                fileFolderName: productImageDirectoryPath,
                isItFolder: true);
            }
          },
        ),
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productBook = Provider.of<ProductBook>(context);

    return ListView.builder(
      shrinkWrap: true,
        itemCount: productBook.productBook.length,
        itemBuilder: (context, index) {
          final product = productBook.productBook[index];
          return InkWell(
            child: ProductListCard(product: product),
            onTap: () async {
              Navigator.of(context).pushNamed(productDetailRoute, arguments: product.productId);
            },
          );
        },
      );
  }
}
