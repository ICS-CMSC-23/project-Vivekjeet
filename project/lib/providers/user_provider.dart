import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../apis/firebase_users_api.dart';

class UsersProvider with ChangeNotifier {
  late FirebaseUserAPI firebaseService;
  late Stream<QuerySnapshot> _usersStream;
  // late Future<DocumentSnapshot<Map<String, dynamic>>> _userDetails;

  UsersProvider() {
    firebaseService = FirebaseUserAPI();
    fetchUsers();
  }

  Stream<QuerySnapshot> get users => _usersStream;
  // Future<DocumentSnapshot<Map<String, dynamic>>> get details => _userDetails;

  void fetchUsers() {
    _usersStream = firebaseService.getAllUsers();
    notifyListeners();
  }

  // void getUserDetails() {
  //   _userDetails = firebaseService.getUserDetails();
  //   notifyListeners();
  // }

  // Future<void> addUser(User item) async {
  //   String message = await firebaseService.addUser(item.toJson(item));
  //   print(message);
  //   notifyListeners();
  // }
}