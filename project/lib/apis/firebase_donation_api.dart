import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDonationAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
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

  Future<String> addDonation(Map<String, dynamic> donation) async {
    try {
      final docRef = await db.collection("donations").add(donation);
      await db.collection("donations").doc(docRef.id).update({'donationId': docRef.id});
      
      return "Successfully added donation!";
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