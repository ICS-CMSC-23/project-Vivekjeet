import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


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

  Future<String> addDrive(Map<String, dynamic> drive, photos) async {
    try {
      final docRef = await db.collection("donationDrives").add(drive);
      await db.collection('donationDrives').doc(docRef.id).update({'driveId': docRef.id});
      final orgRef = drive['organization'];
      final orgId = orgRef.path.split('/').last;
      List<String> urls = [];
      for (int i = 0; i < photos.length; i++) {
        try {
          String imagePath = "users/$orgId/images/donationDrives/${drive['driveName']}/photo$i";
          TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child(imagePath).putFile(photos[i]);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          urls.add(downloadUrl);
        } catch (e) {
          print('Error uploading images $i: $e');
        }
      }
      await db.collection('donationDrives').doc(docRef.id).update({'photos': urls});
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