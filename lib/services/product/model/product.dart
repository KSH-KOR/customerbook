//user adds products in advanced
//when a user creates histories for a customer they can choose the products to add on a history.

// users create them -> generate product + id. -> store it in a cloud
// users choose products id and add to the history.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../constant/fieldname.dart';

class Product{
  final String? name;
  final String? price;
  final String? description;
  bool? isAvailable;
  final String? productImageCloudPath;
  final Timestamp lastModifiedDate;
  final int? sales;
  
  final String productId;
  final String userId;

  final List<ProductImages>? productImages;

  Product(this.productImages, {this.sales = 0, required this.lastModifiedDate, this.name, this.price, this.description, this.isAvailable, required this.productId, required this.userId, required this.productImageCloudPath,});

  Product.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : userId = snapshot.data()[userIdFieldName],
        productId = snapshot.data()[productIdFieldName],
        name = snapshot.data()[productNameFieldName],
        price = snapshot.data()[productPriceFieldName],
        description = snapshot.data()[productDescriptionFieldName],
        isAvailable = snapshot.data()[isProductAvailableFieldName] as bool?,
        lastModifiedDate = snapshot.data()[lastModifiedDateFieldName] as Timestamp? ?? Timestamp.now(),
        productImageCloudPath = snapshot.data()[productImageUrlCloudPathFieldName],
        productImages = (snapshot.data()[productImagesFieldName])?.entries.map<ProductImages>((e) {
          return ProductImages(imageId: e.key, imageDownloadUrl: e.value);
        },).toList(),
        sales = snapshot.data()[salesFieldName] ?? 0;
        
  Product.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
    : userId = snapshot.data()![userIdFieldName],
        productId = snapshot.data()![productIdFieldName],
        name = snapshot.data()![productNameFieldName],
        price = snapshot.data()![productPriceFieldName],
        description = snapshot.data()![productDescriptionFieldName],
        isAvailable = snapshot.data()![isProductAvailableFieldName] as bool?,
        lastModifiedDate = snapshot.data()![lastModifiedDateFieldName] as Timestamp,
        productImageCloudPath = snapshot.data()![productImageUrlCloudPathFieldName],
        productImages = (snapshot.data()![productImagesFieldName])?.entries.map<ProductImages>((e) {
          return ProductImages(imageId: e.key, imageDownloadUrl: e.value);
        },).toList(),
        sales = snapshot.data()![salesFieldName] ?? 0;

  Widget getFirstProductImage(){
    if(productImages == null || productImages!.isEmpty || productImages!.first.imageDownloadUrl == null){
      return Image.asset("assets/images/profile/noimage.jpg");
    }
    return Image.network(productImages!.first.imageDownloadUrl!);
  }
}

class ProductImages{
  final String? imageDownloadUrl;
  final String imageId;
  ProductImages({this.imageDownloadUrl, String? imageId}) :
    imageId = imageId ?? const Uuid().v4();

  
  ProductImages.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
    imageDownloadUrl = snapshot.data()[imageUrlFieldName],
    imageId = snapshot.data()[imageIdFieldName];
}