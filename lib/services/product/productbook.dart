import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customermanager/services/product/constant/fieldname.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';

import 'model/product.dart';

class ProductBook extends ChangeNotifier{
  final productCollection =
         FirebaseFirestore.instance.collection(productCollectionName);
  final List<Product> _productBook = [];
  String? userId;

  CollectionReference<Map<String, dynamic>> getProductImageCollection({required String productId}) => productCollection.doc(productId).collection(productImageCollectionName);

  void setOrSwitchUser({required String userId}){
    this.userId = userId;
    log("product book: user has set successfully [user id: ${this.userId}");
  }

  List<Product> get productBook {
    return _productBook;
  }

  void increaseSalesCount({required String productId}){
    final product = findProductById(productId: productId);
    if(product==null){
      log("cannot find product by id");
      return;
    }
    updateProductInCloud(productId: productId, sales: product.sales != null ? product.sales! + 1 : 1);
    log("product name: ${product.name} puchased!");
    notifyListeners();
  }

  void decreaseSalesCount({required String productId}){
    final product = findProductById(productId: productId);
    if(product==null){
      log("cannot find product by id");
      return;
    }
    updateProductInCloud(productId: productId, sales: (product.sales != null && product.sales! >= 1) ? product.sales! - 1 : 0);
    notifyListeners();
  }

  Product? findProductById({required String productId}) {
    final List<Product?> foundProducts = productBook.where((element) => element.productId == productId).toList();
    if(foundProducts.length != 1){
      foundProducts.isEmpty ? log("error: cannot find the product in local database") : log("error: found more than one product in local database. found: [${foundProducts.length}]");
      if(foundProducts.length > 1){
        while(productBook.where((element) => element.productId == productId).toList().length > 1){
          foundProducts.removeWhere((element) => element!.productId == productId);
        }
        notifyListeners();
        log("removed redundant customers from the local database");
      }
      return null;
    }
    return foundProducts.first!;
  }

  Future<void> fetch() async {
    if(userId == null){
      log("user hasn't been set. set user first");
      return;
    }
    final allProducts = await productCollection.get();
    final products = allProducts.docs.where((element) => element.data()[userIdFieldName] == userId);
    _productBook.clear();
    _productBook.addAll(products.map((e) => Product.fromSnapshot(e)));
    sortList();
    log("poduct list has fetched");
  }

   void sortList(){
    _productBook.sort((Product a, Product b) {
      return a.lastModifiedDate.microsecondsSinceEpoch.compareTo(b.lastModifiedDate.microsecondsSinceEpoch);
    },);
    log("product list has sorted");
  }

  Stream<Iterable<Product>> getProducts({bool isDescending = true}) {
    final products = productCollection
        .orderBy(lastModifiedDateFieldName, descending: isDescending).snapshots()
        .map((event) => event.docs.map((doc) => Product.fromSnapshot(doc)));
    return products;
  }

  Future<void> createOrEidtProductToCloud({
    String? name,
    String? price,
    String? description,
    bool? isAvailable,
    FieldValue? lastModifiedDate,
    String? productId,
    String? productImageCloudDirectoryPath,
    List<ProductImages>? productImages,
    required String userId,
    }) async {
      productId = productId ?? const Uuid().v4();
      lastModifiedDate = lastModifiedDate ?? FieldValue.serverTimestamp();
      final docRef = productCollection.doc(productId);
      Map<String, String>? productImageMap = productImages != null ? { for (var v in productImages) v.imageId: v.imageDownloadUrl! } : null;
    await docRef.set({
      productNameFieldName: name,
      productPriceFieldName: price,
      productDescriptionFieldName: description, 
      isProductAvailableFieldName: isAvailable,
      lastModifiedDateFieldName: lastModifiedDate,
      productIdFieldName: productId,
      userIdFieldName: userId,
      productImageUrlCloudPathFieldName: productImageCloudDirectoryPath,
      productImagesFieldName: productImageMap,
      salesFieldName: 0,
    });
    _productBook.removeWhere((element) => element.productId == productId);
    _productBook.add(Product.fromDocumentSnapshot(await docRef.get()));
    sortList();
    notifyListeners();
  }

  Future<void> updateProductInCloud({
    required String productId,
    String? name,
    String? price,
    String? description,
    bool? isAvailable,
    FieldValue? lastModifiedDate,
    String? productImageCloudDirectoryPath,
    int? sales,
  }) async {
    final product = findProductById(productId: productId);
    if(product == null) return;
    lastModifiedDate = FieldValue.serverTimestamp();
    final docRef = productCollection.doc(productId);
    await docRef.update({
      productNameFieldName: name ?? product.name,
      productPriceFieldName: price ?? product.price,
      productDescriptionFieldName: description ?? product.description,
      isProductAvailableFieldName: isAvailable ?? product.isAvailable,
      lastModifiedDateFieldName: lastModifiedDate,
      productImageUrlCloudPathFieldName: productImageCloudDirectoryPath,
      salesFieldName: sales ?? product.sales,
    });
    _productBook.removeWhere((element) => element.productId == productId);
    _productBook.add(Product.fromDocumentSnapshot(await docRef.get()));
    sortList();
    notifyListeners();
  }

  Future<bool> deleteProductInCloud({required String productId}) async {
    try{
      await productCollection.doc(productId).delete();
      _productBook.removeWhere((element) => element.productId == productId);
      sortList();
      notifyListeners();
      log("customer [id: $productId] is deleted");
      return true;
    } catch(e){
      log("customer [id: $productId] coudn't be deleted");
      return false;
    }
  }

  Stream<Iterable<ProductImages>> getProductImages({required String productId}){
    return getProductImageCollection(productId: productId).where(imageIdFieldName).snapshots().map(
        (event) => event.docs.map(
            (doc) => ProductImages.fromSnapshot(doc),
        )
    );
  }

  Future<bool> deleteProductImageInCould({required String productId, required String imageId}) async {
    try{
      await getProductImageCollection(productId: productId).doc(imageId).delete();
      log("image [id: $imageId] is deleted");
      return true;
    } catch(e){
      log("image [id: $imageId] coudn't be deleted");
      return false;
    }
  }

  Future<bool> createProductImageInCould({required String productId, required String imageUrl}) async {
    try{
      final String imageId = const Uuid().v4();
      final docRef = getProductImageCollection(productId: productId).doc(imageId);
      await docRef.set({
        imageUrlFieldName: imageUrl,
        imageIdFieldName: imageId,
      });
      log("product [id: $imageId] is created");
      return true;
    } catch(e){
      log("product: image coudn't be created");
      return false;
    }
  }

}