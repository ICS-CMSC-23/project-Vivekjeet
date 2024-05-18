import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../apis/firebase_users_api.dart';

class UsersProvider with ChangeNotifier {
  late FirebaseUserAPI firebaseService;
  late Stream<QuerySnapshot> _orgsStream;

  UsersProvider() {
    firebaseService = FirebaseUserAPI();
    fetchOrgs();
  }

  Stream<QuerySnapshot> get organizations => _orgsStream;

  void fetchOrgs() {
    _orgsStream = firebaseService.getAllOrganization();
    notifyListeners();
  }

  // Future<void> addUser(User item) async {
  //   String message = await firebaseService.addUser(item.toJson(item));
  //   print(message);
  //   notifyListeners();
  // }
}