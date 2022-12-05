import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../product/model/product.dart';
import 'model/history.dart';
import 'package:flutter/cupertino.dart';

import 'constant/fieldname.dart';

class HistoryBook extends ChangeNotifier{
  final historyCollection =
         FirebaseFirestore.instance.collection(historyCollectionName);
  final List<History> historyBook = [];
  String? customerId;

  void setOrSwitchCustomer({required String customerId}){
    this.customerId = customerId;
    log("history book: customer has set successfully [customer id: ${this.customerId}");
  }

  Future<void> fetch({required String customerId}) async {
    final allHistories = await historyCollection.get();
    final histories = allHistories.docs.where((element) => element.data()[customerIdFieldName] == customerId);
    historyBook.clear();
    historyBook.addAll(histories.map((e) => History.fromSnapshot(e)));
    log("history book: history has fetched");
    sortList();
    notifyListeners();
  }
  Future<void> fetchAll() async {
    final allHistories = await historyCollection.get();
    final histories = allHistories.docs;
    historyBook.clear();
    historyBook.addAll(histories.map((e) => History.fromSnapshot(e)));
    log("history book: history has fetched");
    sortList();
    notifyListeners();
  }
  void sortList(){
    historyBook.sort((History a, History b) {
      return a.date.microsecondsSinceEpoch.compareTo(b.date.microsecondsSinceEpoch);
    },);
    log("history list has sorted");
  }
  Stream<Iterable<History>> allHistories({bool isDescending = true}) {
    final histories = historyCollection
        .orderBy(historyDateFieldName, descending: isDescending).snapshots()
        .map((event) => event.docs.map((doc) => History.fromSnapshot(doc)));
    return histories;
  }

  Future<void> createOrEidtHistoryToCloud({
    String? historyId,
    String? description,
    FieldValue? writtenDate,
    List<String>? selectedProductIds,
    required String customerId,
  }) async {
    historyId = historyId ?? const Uuid().v4();
    writtenDate = writtenDate ?? FieldValue.serverTimestamp();
    final docRef = historyCollection.doc(historyId);
    await historyCollection.doc(historyId).set({
      historyDateFieldName: writtenDate,
      historyDescriptionFieldName: description,
      historyIdFieldName: historyId,
      customerIdFieldName: customerId,
      selectedProductIdsFieldName: selectedProductIds,
    });
    historyBook.removeWhere((element) => element.historyId == historyId);
    historyBook.add(History.fromDocumentSnapshot(await docRef.get()));
    sortList();
    notifyListeners();
  }

  Future<void> editHistoryToCloud({
    required String historyId,
    String? description, 
  }) async {
    await historyCollection.doc(historyId).update({
      historyDescriptionFieldName: description,
    });
  }

  Future<bool> removeHistoryToCloud({required String historyId}) async {
    try{
      await historyCollection.doc(historyId).delete();
      historyBook.removeWhere((element) => element.historyId == historyId);
      sortList();
      notifyListeners();
      log("history [id: $historyId] is deleted");
      return true;
    } catch(e){
      log("history [id: $historyId] coudn't be deleted");
      return false;
    }
  }
}