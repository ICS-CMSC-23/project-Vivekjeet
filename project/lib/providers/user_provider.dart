import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../apis/firebase_user_api.dart';

class UsersProvider with ChangeNotifier {
  late FirebaseUserAPI firebaseService;
  late Stream<QuerySnapshot> _orgsStream;
  Stream<DocumentSnapshot>? _selectedOrgStream;

  UsersProvider() {
    firebaseService = FirebaseUserAPI();
    fetchOrganizations();
  }

  Stream<QuerySnapshot> get organizations => _orgsStream;
  Stream<DocumentSnapshot>? get selectedOrganization => _selectedOrgStream;

  void fetchOrganizations() {
    _orgsStream = firebaseService.getAllOrganizations();
    notifyListeners();
  }

  void fetchOrganizationDetails(String orgId) {
    _selectedOrgStream = firebaseService.getOrganizationDetails(orgId);
    notifyListeners();
  }

  // Future<void> addUser(User item) async {
  //   String message = await firebaseService.addUser(item.toJson(item));
  //   print(message);
  //   notifyListeners();
  // }
}