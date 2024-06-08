import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDonationAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  User? user = auth.currentUser;

  Future<DocumentSnapshot> getDonationById(String donationId) async {
    return await db.collection('donations').doc(donationId).get();
  }

  Stream<QuerySnapshot> getDonations() {
    DocumentReference orgRef = db.doc('users/${user!.uid}');
    return db
        .collection('donations')
        .where('organization', isEqualTo: orgRef)
        .snapshots();
  }

  Stream<QuerySnapshot> getDonationsByDonor(String donorId) {
    return db
        .collection('donations')
        .where('donor', isEqualTo: db.doc('users/$donorId'))
        .snapshots();
  }

  Stream<QuerySnapshot> getDonationsByDonorToOrganization(String donorId, String orgId) {
    return db
        .collection('donations')
        .where('donor', isEqualTo: db.doc('users/$donorId'))
        .where('organization', isEqualTo: db.doc('users/$orgId'))
        .snapshots();
  }

  Stream<QuerySnapshot> getDonationsOfOrganization(String orgId) {
    return db
        .collection('donations')
        .where('organization', isEqualTo: db.doc('users/$orgId'))
        .snapshots();
  }

  Future<List<String>> uploadPhotos(String orgId, String donationId, List<File> photos) async {
    List<String> urls = [];
    for (int i = 0; i < photos.length; i++) {
      try {
        String imagePath = "users/$orgId/images/donations/$donationId/photo$i";
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child(imagePath).putFile(photos[i]);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        urls.add(downloadUrl);
      } catch (e) {
        print('Error uploading images $i: $e');
      }
    }
    return urls;
  }

  Future<String> addDonation(Map<String, dynamic> donation, photos) async {
    try {
      print("Adding donation...");
      final docRef = await db.collection("donations").add(donation);
      await db.collection('donations').doc(docRef.id).update({'donationId': docRef.id});
      print("Donation added with ID: ${docRef.id}");
      final orgRef = donation['organization'];
      final orgId = orgRef.path.split('/').last;

      List<String> urls = await uploadPhotos(orgId, docRef.id, photos);
      await db.collection('donations').doc(docRef.id).update({'photos': urls});
      
      print('Donation added successfully!');
      
      return docRef.id;
    } on FirebaseException catch (e) {

      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteDonation(String? donationId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('donations')
          .where('donationId', isEqualTo: donationId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await db.collection('donations').doc(donationId).delete();

        return "Successfully deleted!";
      } else {
        return "Donation not found!";
      }
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<void> updateStatus(String? donationId, String newStatus) async {
    await db.collection('donations').doc(donationId).update({'status': newStatus});
  }
}