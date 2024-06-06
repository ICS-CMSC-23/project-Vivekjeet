import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../apis/firebase_user_api.dart';

class UsersProvider with ChangeNotifier {
  late FirebaseUserAPI firebaseService;
  late Stream<DocumentSnapshot> _selectedOrgStream;
  late Stream<QuerySnapshot> _orgsStream;
  late Stream<DocumentSnapshot> _uid;


  UsersProvider() {
    firebaseService = FirebaseUserAPI();
    fetchOrganizations();
  }

  Stream<DocumentSnapshot> get selectedOrganization => _selectedOrgStream;
  Stream<QuerySnapshot> get organizations => _orgsStream;
  Stream<DocumentSnapshot> get userId => _uid;

  void fetchOrganizationById(String orgId) {
    _selectedOrgStream = firebaseService.getOrganizationById(orgId);
    notifyListeners();
  }

  void fetchOrganizations() {
    _orgsStream = firebaseService.getAllOrganizations();
    notifyListeners();
  }

  void fetchUserById(String userId) {
    _uid = firebaseService.getUserById(userId);
    notifyListeners();
  }

  void editOrg(String? id, String username, String orgname, String contact, String description) async {
    String message = await firebaseService.editOrg(id, username, orgname, contact, description);
    print(message);
    notifyListeners();
  }

  void uploadProfilePicture(String? id, File profilePicture) async {
    String message = await firebaseService.uploadProfilePicture(id, profilePicture);
    print(message);
    notifyListeners();
  }
}