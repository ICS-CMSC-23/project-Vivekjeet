import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../apis/firebase_user_api.dart';

class UsersProvider with ChangeNotifier {
  late FirebaseUserAPI firebaseService;
  late Stream<DocumentSnapshot> _selectedOrgStream;
  late Stream<QuerySnapshot> _orgsStream;
  late Stream<QuerySnapshot> _donorsStream;
  late Stream<DocumentSnapshot> _uid;


  UsersProvider() {
    firebaseService = FirebaseUserAPI();
    fetchOrganizations();
  }

  Stream<DocumentSnapshot> get selectedOrganization => _selectedOrgStream;
  Stream<QuerySnapshot> get organizations => _orgsStream;
  Stream<QuerySnapshot> get donors => _donorsStream;
  Stream<DocumentSnapshot> get userId => _uid;

  Future fetchOrganizationById(String orgId) async {
    _selectedOrgStream = await firebaseService.getOrganizationById(orgId);
    notifyListeners();
    return _selectedOrgStream;
  }

  void fetchOrganizations() {
    _orgsStream = firebaseService.getAllOrganizations();
    notifyListeners();
  }

  void fetchDonors() {
    _donorsStream = firebaseService.getAllDonors();
    notifyListeners();
  }

  void fetchUserById(String userId) {
    _uid = firebaseService.getUserById(userId);
    notifyListeners();
  }

  void editOrg(String? id, String username, String orgname, String contact, String description, List<String> addresses) async {
    String message = await firebaseService.editOrg(id, username, orgname, contact, description, addresses);
    print(message);
    notifyListeners();
  }

  void editOrgStatus(String? id, bool status) async {
    String message = await firebaseService.editOrgStatus(id, status);
    print(message);
    notifyListeners();
  }

  void uploadProfilePicture(String? id, File profilePicture) async {
    String message = await firebaseService.uploadProfilePicture(id, profilePicture);
    print(message);
    notifyListeners();
  }
}