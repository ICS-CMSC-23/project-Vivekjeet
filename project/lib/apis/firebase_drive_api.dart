import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/drive_model.dart';


class FirebaseDriveAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getDrivesOfOrganization(String organizationId) {
    return db
        .collection('donationDrives')
        .where('organization', isEqualTo: db.doc(organizationId))
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

      List<String> urls = await uploadPhotos(orgId, docRef.id, photos);
      await db.collection('donationDrives').doc(docRef.id).update({'photos': urls});
      
      return "Successfully added drive!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<List<String>> uploadPhotos(String orgId, String driveId, List<File> photos) async {
    List<String> urls = [];
    for (int i = 0; i < photos.length; i++) {
      try {
        String imagePath = "users/$orgId/images/donationDrives/$driveId/photo$i";
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child(imagePath).putFile(photos[i]);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        urls.add(downloadUrl);
      } catch (e) {
        print('Error uploading images $i: $e');
      }
    }
    return urls;
  }

  Future<void> updateDrive(String driveId, DriveModel updatedDrive, List<File> newDriveImages, List<String> removedPhotos) async {
    try {
      // Delete removed photos from Firebase Storage
      for (String photoUrl in removedPhotos) {
        await _deletePhotoFromStorage(photoUrl);
      }

      // Upload new photos to Firebase Storage and get the download URLs
      final orgRef = updatedDrive.organization;
      final orgId = orgRef.path.split('/').last;
      List<String> newPhotoUrls = [];
      for (int i = 0; i < newDriveImages.length; i++) {
        try {
          String imagePath = "users/$orgId/images/donationDrives/$driveId/photo${updatedDrive.photos.length + i}";
          TaskSnapshot snapshot = await storage.ref().child(imagePath).putFile(newDriveImages[i]);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          newPhotoUrls.add(downloadUrl);
        } catch (e) {
          print('Error uploading image $i: $e');
        }
      }

      // Combine existing photos and new photo URLs
      List<String> updatedPhotos = [...updatedDrive.photos, ...newPhotoUrls];

      // Update the Firestore document with the new details
      await db.collection('donationDrives').doc(driveId).update({
        'driveName': updatedDrive.driveName,
        'description': updatedDrive.description,
        'photos': updatedPhotos,
      });
    } catch (e) {
      print('Error updating drive: $e');
    }
  }

  Future<void> _deletePhotoFromStorage(String photoUrl) async {
    try {
      Reference photoRef = storage.refFromURL(photoUrl);
      await photoRef.delete();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

    Future<String> deleteDrive(String? driveId, List<String> photos) async {
    try {
      for (String photoUrl in photos) {
        await storage.refFromURL(photoUrl).delete();
      }

      // Delete the Firestore document
      await db.collection('donationDrives').doc(driveId).delete();
      return "Successfully Deleted";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  Future<void> removeDonationFromDrive(String driveId, String donationId) async {
    try {
      String path = "donations/$donationId";
      DocumentReference pathref = db.doc(path);
      await db.collection('donationDrives').doc(driveId).update({
        'donations': FieldValue.arrayRemove([pathref]),
      });
    } catch (e) {
      print('Error removing donation from drive: $e');
    }
  }

}