import 'dart:developer';
import 'dart:io';

import 'package:customermanager/services/product/productbook.dart';
import 'package:customermanager/widgets/available_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';

import '../../services/product/model/product.dart';
import '../../widgets/helpers.dart';

import 'package:intl/intl.dart' show DateFormat;

import '../customer/customer_detail_view.dart';

enum MenuAction { delete, cancel }

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  Widget build(BuildContext context) {
    late final String arg;
    try {
      arg = ModalRoute.of(context)!.settings.arguments as String;
    } catch (e) {
      log("detail page: got wrong argument. error msg:$e");
      Navigator.of(context).pop();
    }
    final productBook = Provider.of<ProductBook>(context, listen: false);
    final product = productBook.findProductById(productId: arg);
    if (product == null) {
      log("error: cannot find product in local database. productId: $arg");
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
            await productBook.updateProductInCloud(productId: product!.productId);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product!.productImages == null
                ? const SizedBox(
                    height: 150,
                    child: Text("no images"),
                  )
                : ImageSwiper(
                    height: 150,
                    imagePathOrUrl: product.productImages!
                        .map((e) => e.imageDownloadUrl)
                        .toList()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32 - 8),
              child: Row(
                children: [
                  Text(
                    "sales count: ${product.sales}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  AvailableToggleButton(productId: product.productId),
                ],
              ),
            ),
            const AddVerticalSpace(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32 - 8,
              ),
              child: ContactInformationSheet(
                product: product,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageSwiper extends StatelessWidget {
  const ImageSwiper({
    Key? key,
    required this.imagePathOrUrl,
    this.height = 250,
    this.isPreview = false,
  }) : super(key: key);

  final double height;
  final List<String?> imagePathOrUrl;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          if(imagePathOrUrl[index] == null ) return Image.asset("assets/images/profile/profile_default_img.png",);
          
          return isPreview
              ? Image.file(
                  File(imagePathOrUrl[index]!),
                  fit: BoxFit.contain,
                )
              : Image.network(
                  imagePathOrUrl[index]!,
                  fit: BoxFit.contain,
                );
        },
        autoplay: true,
        itemCount: imagePathOrUrl.length,
        pagination: const SwiperPagination(),
        control: const SwiperControl(),
      ),
    );
  }
}

class ContactInformationSheet extends StatelessWidget {
  const ContactInformationSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Product Information"),
          const AddVerticalSpace(height: 20),
          InformationCard(
            title: "Product name",
            contents: product.name ?? "no name",
          ),
          const AddVerticalSpace(height: 20),
          InformationCard(
            title: "Price:",
            contents: product.price ?? "no data yet",
          ),
          const AddVerticalSpace(height: 20),
          InformationCard(
            title: "Description:",
            contents: product.description ?? "no description",
          ),
          const AddVerticalSpace(height: 20),
          InformationCard(
              title: "last modified date:",
              contents: DateFormat("yyyy-MM-dd").format(
                  DateTime.fromMicrosecondsSinceEpoch(
                      product.lastModifiedDate.microsecondsSinceEpoch))),
        ],
      ),
    );
  }
}
