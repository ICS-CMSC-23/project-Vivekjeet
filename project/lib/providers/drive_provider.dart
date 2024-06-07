// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/drive_model.dart';
import '../apis/firebase_drive_api.dart';

class DriveProvider with ChangeNotifier {
  late FirebaseDriveAPI firebaseService;
  late Stream<QuerySnapshot> _drivesStream;
  List<DocumentReference> _donationsOfDrive = [];
  late DocumentSnapshot _selectedDriveStream;

  DriveProvider() {
    firebaseService = FirebaseDriveAPI();
  }

  Stream<QuerySnapshot> get drives => _drivesStream;
  List<DocumentReference> get donationReferences => _donationsOfDrive;
  DocumentSnapshot<Object?> get selectedDrive => _selectedDriveStream;

  void loadDrivesOfOrganization(String organizationId) {
    _drivesStream = firebaseService.getDrivesOfOrganization(organizationId);
    notifyListeners();
  }

  Future<void> loadDonationsOfDrive(String driveId) async {
    _donationsOfDrive = await firebaseService.getDonationsOfDrive(driveId);
    notifyListeners();
  }

  void fetchDriveById(String driveId) async {
    _selectedDriveStream = await firebaseService.getDriveById(driveId);
    notifyListeners();
  }

  Future<void> addDrive(DriveModel drive, List<File> photos) async {
    String message = await firebaseService.addDrive(drive.toJson(drive), photos);
    notifyListeners(); 
    print(message);
  }

  void deleteDrive(String? driveId) async {
    String message = await firebaseService.deleteDonation(driveId);
    print(message);
    notifyListeners();
  }

  void editDrive(String driveId, String newDriveName, String newDescription, List<String> newPhotos) async {
    String message = await firebaseService.editDrive(driveId, newDriveName, newDescription, newPhotos);
    print(message);
    notifyListeners();
  }
}