// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/drive_model.dart';
import '../apis/firebase_drive_api.dart';

class DriveProvider with ChangeNotifier {
  late FirebaseDriveAPI firebaseService;
  // late Stream<QuerySnapshot> _drivesStream;

  DriveProvider() {
    firebaseService = FirebaseDriveAPI();
  }

  // Stream<QuerySnapshot> get drives => _drivesStream;

  // void loadDrives(String organizationId) {
  //   _drivesStream = firebaseService.getDrives(organizationId);
  //   notifyListeners();
  // }

  void addDrive(DriveModel drive) async {
    String message = await firebaseService.addDrive(drive.toJson(drive));
    notifyListeners(); 
    print(message);
  }

  void deleteDrive(String? driveId) async {
    String message = await firebaseService.deleteDonation(driveId);
    print(message);
    notifyListeners();
  }
}