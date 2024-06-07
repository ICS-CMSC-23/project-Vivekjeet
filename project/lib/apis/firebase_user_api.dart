
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // Future<String> addUser(Map<String, dynamic> user) async {
  //   try {
  //     final docRef = await db.collection("users").add(user);
  //     await db.collection("users").doc(docRef.id).update({'id': docRef.id});

  //     return "Successfully added user!";
  //   } on FirebaseException catch (e) {
  //     return "Failed with error '${e.code}: ${e.message}";
  //   }
  // }

  Stream<DocumentSnapshot> getOrganizationById(String orgId) {
    return db.collection("users").doc(orgId).snapshots();
  }

  Stream<QuerySnapshot> getAllOrganizations() {
    return db.collection("users")
          .where('type', isEqualTo: 'Organization')
          .snapshots();
  }

  Stream<DocumentSnapshot> getUserById(String userId) {
    return db.collection("users").doc(userId).snapshots();
  }
  
  Future<String> editOrg(String? id, String username, String orgname, String contact, String description) async {
    try {
      await db.collection('users').doc(id).update({
        'userName': username,
        'organizationName': orgname,
        'contactNumber': contact,
        'description': description,
      });
      return "Successfully Edited Organization!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> uploadProfilePicture(String? id, File profilePicture) async {
    try{
      String imagePath = "users/$id/images/profilepicture";
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child(imagePath).putFile(profilePicture);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await db.collection('users').doc(id).update({'profilePicture': downloadUrl});
      return "Successfully uploaded profile picture";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}