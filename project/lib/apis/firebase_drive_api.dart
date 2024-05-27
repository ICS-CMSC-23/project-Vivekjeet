import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseDriveAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getDrivesOfOrganization(String organizationId) {
    return db
        .collection('donationDrives')
        .where('organization', isEqualTo: db.doc('users/$organizationId'))
        .snapshots();
  }

  Future<List<DocumentReference>> getDonationsOfDrive(String driveId) async {
    try {
      DocumentSnapshot driveDoc = await db.collection('donationDrives').doc(driveId).get();
      if (driveDoc.exists) {
        List<DocumentReference> donations = List<DocumentReference>.from(driveDoc['donations']);
        return donations;
      } else {
        throw Exception("Drive not found");
      }
    } catch (e) {
      print("Failed to get donation references: $e");
      return [];
    }
  }
  
  Future<DocumentSnapshot> getDriveById(String driveId) async {
    return await db.collection('donationDrives').doc(driveId).get();
  }

  Future<String> addDrive(Map<String, dynamic> drive) async {
    try {
      final docRef = await db.collection("donationDrive").add(drive);
      await db.collection("donationDrive").doc(docRef.id).update({'donationId': docRef.id});
      
      return "Successfully added drive!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteDonation(String? driveId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('donationDrives')
          .where('driveId', isEqualTo: driveId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await db.collection('donationDrives').doc(driveId).delete();

        return "Successfully deleted!";
      } else {
        return "Drive not found!";
      }
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<String> editDrive(String? driveId, String newDriveName, String newDescription, List<String> newPhotos) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('donationDrives')
          .where('driveId', isEqualTo: driveId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {

        await db.collection('friends').doc(driveId).update({"driveName": newDriveName});
        await db.collection('friends').doc(driveId).update({"description": newDescription});
        await db.collection('friends').doc(driveId).update({"photos": newPhotos});

        return "Successfully edited!";
      } else {
        return "Drive not found!";
      }
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}