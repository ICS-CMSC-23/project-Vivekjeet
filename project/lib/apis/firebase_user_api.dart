import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  Stream<QuerySnapshot> getAllOrganizations() {
    return db.collection("users")
          .where('type', isEqualTo: 'Organization')
          .snapshots();
  }

  Stream<DocumentSnapshot> getOrganizationDetails(String orgId) {
    return db.collection("users").doc(orgId).snapshots();
  }

  // DocumentSnapshot<Map<String, dynamic>>> getUserDetails() {
  //   return db.collection('user').doc(auth.currentUser?.uid).get();
  // }

}