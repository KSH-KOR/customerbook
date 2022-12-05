import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant/fieldname.dart';


class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final bool isAnonymous;
  final String? photoURL;
  final String? phoneNumber;
  AuthUser({
    required this.isAnonymous,
    required this.id,
    this.photoURL, 
    this.phoneNumber,
    this.name,
    this.email, 
  });

  AuthUser.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : name = snapshot.data()[userNameFieldName],
        email = snapshot.data()[userEmailFieldName],
        id = snapshot.data()[userIdFieldName],
        isAnonymous = snapshot.data()[userNameFieldName] == null || snapshot.data()[userEmailFieldName] == null,
        photoURL = snapshot.data()[userProfileURLFieldName],
        phoneNumber = snapshot.data()[userPhoneNUmberFieldName];

  // create authuser from firebase user
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid, 
        isAnonymous: user.isAnonymous,
        name: user.displayName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        photoURL: user.photoURL,
      );
}