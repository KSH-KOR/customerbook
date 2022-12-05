
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../constant/fieldname.dart';

class Customer {
  final String customerId;
  final String userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final Timestamp registerDate;
  bool isFavorited;

  Customer({
    required this.customerId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.registerDate,
    required this.isFavorited,
  });
  Customer.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : userId = snapshot.data()[userIdFieldName],
        name = snapshot.data()[customerNameFieldName],
        email = snapshot.data()[customerEmailFieldName],
        phoneNumber = snapshot.data()[customerPhoneNumberFieldName],
        profileImageUrl = snapshot.data()[customerProfileImageUrlFieldName],
        isFavorited = snapshot.data()[customerIsFavoritedFieldName],
        registerDate = snapshot.data()[customerRegisterFieldName] as Timestamp,
        customerId = snapshot.data()[customerIdFieldName];

  Customer.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
    : userId = snapshot.data()![userIdFieldName],
        name = snapshot.data()![customerNameFieldName],
        email = snapshot.data()![customerEmailFieldName],
        phoneNumber = snapshot.data()![customerPhoneNumberFieldName],
        profileImageUrl = snapshot.data()![customerProfileImageUrlFieldName],
        isFavorited = snapshot.data()![customerIsFavoritedFieldName],
        registerDate = snapshot.data()![customerRegisterFieldName] as Timestamp,
        customerId = snapshot.data()![customerIdFieldName];

  factory Customer.fromUserInputs({
    required String? customerId,
    required String userId,
    required String? name,
    required String? email,
    required String? phoneNumber,
    required String? profileImageUrl,
    required bool? isFavorited,
    required Timestamp registerDate,
  }) => Customer(
    customerId: customerId ?? const Uuid().v4(),
    email: email,
    name: name,
    phoneNumber: phoneNumber,
    profileImageUrl: profileImageUrl,
    registerDate: registerDate,
    isFavorited: isFavorited ?? false,
    userId: userId,
  );

  Widget getProfileImage({double width = 50, double height = 50}){
    return AvatarProfile(profileImageUrl: profileImageUrl, width: width, height: height,);
  }
}

class AvatarProfile extends StatelessWidget {
  const AvatarProfile({
    Key? key,
    required this.profileImageUrl,
    this.width = 50,
    this.height = 50,
    this.isLocalPath = false,
  }) : super(key: key);

  final String? profileImageUrl;
  final double width;
  final double height;
  final bool isLocalPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, 
      height: height, 
      child: profileImageUrl == null ? 
        CircularProfileAvatar(
          "",
          child: Image.asset("assets/images/profile/profile_default_img.png",),
        ) : isLocalPath ? 
          CircularProfileAvatar(
          "",
          child: Image.file(File(profileImageUrl!)),
           ) :
          CircularProfileAvatar(
            profileImageUrl!,
            cacheImage: true, 
          ),
    );
  }
}