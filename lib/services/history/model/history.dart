import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';import '../constant/fieldname.dart';

class History{
  final Timestamp date;
  final String? description;
  final String customerId;
  final String historyId;
  final List<String>? selectedProductIds;

  History({
    required this.date,
    required this.description,
    required this.customerId,
    required this.historyId,
    required this.selectedProductIds,
  });

  History.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : date = snapshot.data()[historyDateFieldName] as Timestamp,
        description = snapshot.data()[historyDescriptionFieldName],
        customerId = snapshot.data()[customerIdFieldName],
        historyId = snapshot.data()[historyIdFieldName],
        selectedProductIds = List<String>.from(snapshot.data()[selectedProductIdsFieldName] ?? []);

  History.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot)
      : date = documentSnapshot.data()![historyDateFieldName] as Timestamp,
        description = documentSnapshot.data()![historyDescriptionFieldName],
        customerId = documentSnapshot.data()![customerIdFieldName],
        historyId = documentSnapshot.data()![historyIdFieldName],
        selectedProductIds = List<String>.from(documentSnapshot.data()![selectedProductIdsFieldName] ?? []);
  
  factory History.fromUserInputs({
    required Timestamp date,
    required String? description,
    required String customerId,
    required String? historyId,
    required List<String>? selectedProductIds,
  }) => History(
    date: date,
    customerId: customerId,
    description: description,
    historyId: historyId ?? const Uuid().v4(),
    selectedProductIds: selectedProductIds ?? [],
  );

  
}