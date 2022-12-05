import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'model/customer.dart';
import 'package:flutter/cupertino.dart';

import 'constant/enum.dart';
import 'constant/fieldname.dart';

class CustomerBook extends ChangeNotifier{
  final customerCollection =
         FirebaseFirestore.instance.collection(customerCollectionName);
  final List<Customer> _customerBook = [];
  String? userId;

  CustomerDisplayOrder _dropdownValue = CustomerDisplayOrder.ascending;
  CustomerDisplayOrder get dropdownValue => _dropdownValue;
  set dropdownValue(CustomerDisplayOrder newVal){
    _dropdownValue = newVal;
    notifyListeners();
  }

  void setOrSwitchUser({required String userId}){
    this.userId = userId;
    log("customer book: user has set successfully [user id: ${this.userId}");
  }

  List<Customer> get customerBook {
    return _customerBook;
  }


  Customer? findCustomerById({required String customerId}) {
    final List<Customer?> foundCustomers = customerBook.where((element) => element.customerId == customerId).toList();
    if(foundCustomers.length != 1){
      foundCustomers.isEmpty ? log("error: cannot find the customer in local database") : log("error: found more than one customer in local database. found: [${foundCustomers.length}]");
      if(foundCustomers.length > 1){
        while(customerBook.where((element) => element.customerId == customerId).toList().length > 1){
          foundCustomers.removeWhere((element) => element!.customerId == customerId);
        }
        notifyListeners();
        log("removed redundant customers from the local database");
      }
      return null;
    }
    return foundCustomers.first!;
  }

  Future<void> fetch() async {
    if(userId == null){
      log("user hasn't been set. set user first");
      return;
    }
    final allCustomers = await customerCollection.get();
    final customers = allCustomers.docs.where((element) => element.data()[userIdFieldName] == userId);
    _customerBook.clear();
    _customerBook.addAll(customers.map((e) => Customer.fromSnapshot(e)));
    log("customer list has fetched");
  }

   void sortList(){
    _customerBook.sort((Customer a, Customer b) {
      return a.registerDate.microsecondsSinceEpoch.compareTo(b.registerDate.microsecondsSinceEpoch);
    },);
    log("customer list has sorted");
  }

  Stream<Iterable<Customer>> getCustomers({bool isDescending = true}) {
    final customers = customerCollection
        .orderBy(customerNameFieldName, descending: isDescending).snapshots()
        .map((event) => event.docs.map((doc) => Customer.fromSnapshot(doc)));
    return customers;
  }

  Future<void> createOrEidtCustomerToCloud({
    String? customerId,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    required bool isFavorited,
    FieldValue? registerDate,
    required String userId,
    }) async {
      customerId = customerId ?? const Uuid().v4();
      registerDate = registerDate ?? FieldValue.serverTimestamp();
      final docRef = customerCollection.doc(customerId);
    await docRef.set({
      customerNameFieldName: name,
      customerEmailFieldName: email,
      customerPhoneNumberFieldName: phoneNumber, 
      customerProfileImageUrlFieldName: profileImageUrl,
      customerIsFavoritedFieldName: isFavorited,
      customerRegisterFieldName: registerDate,
      customerIdFieldName: customerId,
      userIdFieldName: userId
    });
    _customerBook.removeWhere((element) => element.customerId == customerId);
    _customerBook.add(Customer.fromDocumentSnapshot(await docRef.get()));
    sortList();
    notifyListeners();
  }

  Future<void> editCustomerToCloud({
    required String customerId,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isFavorited,
  }) async {
    final customer = findCustomerById(customerId: customerId);
    if(customer == null) return;
    final docRef = customerCollection.doc(customerId);
    await docRef.update({
      customerNameFieldName: name ?? customer.name,
      customerEmailFieldName: email ?? customer.email,
      customerPhoneNumberFieldName: phoneNumber ?? customer.phoneNumber,
      customerProfileImageUrlFieldName: profileImageUrl ?? customer.profileImageUrl,
      customerIsFavoritedFieldName: isFavorited ?? customer.isFavorited,
    });
    _customerBook.removeWhere((element) => element.customerId == customerId);
    _customerBook.add(Customer.fromDocumentSnapshot(await docRef.get()));
    sortList();
    notifyListeners();
  }

  Future<bool> removeCustomerToCloud({required String customerId}) async {
    try{
      await customerCollection.doc(customerId).delete();
      _customerBook.removeWhere((element) => element.customerId == customerId);
      notifyListeners();
      log("customer [id: $customerId] is deleted");
      return true;
    } catch(e){
      log("customer [id: $customerId] coudn't be deleted");
      return false;
    }
  }

  
}