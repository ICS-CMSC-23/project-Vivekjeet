import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/drive_model.dart';
import '../apis/firebase_drive_api.dart';
import 'package:provider/provider.dart';

class DriveProvider with ChangeNotifier {
  late FirebaseDriveAPI firebaseService;
  Stream<QuerySnapshot>? _drivesStream;
  List<DocumentReference> _donationsOfDrive = [];
  DocumentSnapshot? _selectedDriveStream;

  DriveProvider() : firebaseService = FirebaseDriveAPI();

  Stream<QuerySnapshot>? get drives => _drivesStream;
  List<DocumentReference> get donationReferences => _donationsOfDrive;
  DocumentSnapshot? get selectedDrive => _selectedDriveStream; // Nullable return type

  Stream<QuerySnapshot> loadDrivesOfOrganization(String organizationId) {
    _drivesStream = firebaseService.getDrivesOfOrganization(organizationId);
    notifyListeners();
    return _drivesStream!;
  }

  Future<void> loadDonationsOfDrive(String driveId) async {
    _donationsOfDrive = await firebaseService.getDonationsOfDrive(driveId);
    notifyListeners();
  }

  Future<DocumentSnapshot> fetchDriveById(String driveId) async {
    _selectedDriveStream = await firebaseService.getDriveById(driveId);
    notifyListeners();
    return _selectedDriveStream!;
  }

  Future<void> addDrive(DriveModel drive, List<File> photos) async {
    String message = await firebaseService.addDrive(drive.toJson(drive), photos);
    notifyListeners(); 
    print(message);
  }

  void deleteDrive(String? driveId, List<String> photos) async {
    String message = await firebaseService.deleteDrive(driveId, photos);
    print(message);
    notifyListeners();
  }

  Future<void> updateDrive(String driveId, DriveModel newDrive, List<File> newPhotos, List<String> removedPhotos) async {
    await firebaseService.updateDrive(driveId, newDrive, newPhotos, removedPhotos);
    notifyListeners();
  }

  Future<void> removeDonationFromDrive(String driveId, String donationId) async {
    await firebaseService.removeDonationFromDrive(driveId, donationId);
  }

  Future<void> addDonationToDrive(String driveId, String donationId) async {
    await firebaseService.addDonationToDrive(driveId, donationId);
  }
}
