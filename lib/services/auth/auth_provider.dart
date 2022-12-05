

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../constants/execeptions.dart';
import '../customer/customerbook.dart';
import '../customer/model/customer.dart';
import 'constant/fieldname.dart';
import 'model/auth_user.dart';

enum FavoriteAction{
  unFavorite, favorite
}

class AuthProvider extends ChangeNotifier{
  final users = FirebaseFirestore.instance.collection(authCollectionName);
  
  final List<String> favoritedCustomers = []; //store customer ids

  final String _defaultImageURL = "https://handong.edu/site/handong/res/img/logo.png";
  String get defaultImageURL => _defaultImageURL;

  Image getProfileImage(){
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String? url = AuthUser.fromFirebase(user).photoURL;
      return Image.network(url ?? defaultImageURL);
    } else {
      log("someting went wrong. could not find auth");
      return Image.network(defaultImageURL);
    }
  }

  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if(googleUser == null){
        throw GoogleSignInExeception;
      } 

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);

    addAuthToDatabase();
    notifyListeners();
  }

  Future anonymouslogIn() async {
    await FirebaseAuth.instance.signInAnonymously();
    addAuthToDatabase();
    notifyListeners();
  }

  Future<void> signout() async {
    final AuthUser? user = currentUser;
    if (user != null) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {
        throw GenericAuthException();
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
    notifyListeners();
  }

  Future<void> createAuthToCloud() async {
    final AuthUser? user = currentUser;
    if(user == null){
      log("error: user cannot find");
      return;
    }
    await users.doc(user.id).set({
      userIdFieldName: user.id,
      userNameFieldName: user.name,
      userEmailFieldName: user.email,
      userPhoneNUmberFieldName: user.phoneNumber,
      userProfileURLFieldName: user.photoURL,
    });
  }

  void addAuthToDatabase(){
    final AuthUser? user = currentUser;
    if(user != null){
      final usersRef = users.doc(user.id);
      usersRef.get().then((docSnapshot) async => {
          if (!docSnapshot.exists)
            {
              await createAuthToCloud(),
            }else{
              log("already added"),
            }
        });
    }
  }

  Future<void> toggleFavoriteCustomer({required String customerId, required BuildContext context}) async {
    final customerBook = Provider.of<CustomerBook>(context);
    
    final Customer? customer = await customerBook.findCustomerById(customerId: customerId);
    if(customer == null) return;
    if(customer.isFavorited != favoritedCustomers.contains(customerId)){
      log("error: customer id[${customer.customerId}] favorite status is different.");
      log("mathcing them to all false..");
      if(currentUser == null){
        log("error: cannot find user information");
        return;
      }
      unFavoriteCustomer(customerId: customerId);
      customerBook.editCustomerToCloud(customerId: customerId, isFavorited: false);
      return;
    }
    customerBook.editCustomerToCloud(customerId: customerId, isFavorited: !favoritedCustomers.contains(customerId));
    favoritedCustomers.contains(customerId) ? unFavoriteCustomer(customerId: customerId) : favoriteCustomer(customerId: customerId);
  }

  FavoriteAction favoriteCustomer({required String customerId}){
    favoritedCustomers.add(customerId);
    notifyListeners();
    return FavoriteAction.favorite;
  }

  FavoriteAction unFavoriteCustomer({required String customerId}){
    favoritedCustomers.remove(customerId);
    notifyListeners();
    return FavoriteAction.unFavorite;
  }

  Stream<User?> getAuthStateChanges() => FirebaseAuth.instance.authStateChanges();
}