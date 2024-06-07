import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriveModel {
  String? driveId;
  List<DocumentReference> donations;
  DocumentReference organization;
  String driveName;
  String description;
  List<String> photos;

  DriveModel({
    this.driveId,
    required this.donations,
    required this.organization,
    required this.driveName,
    required this.description,
    required this.photos
  });

  factory DriveModel.fromJson(Map<String, dynamic> json) {
    return DriveModel(
      driveId: json['driveId'],
      donations: List<DocumentReference>.from(json['donations']),
      organization: json['organization'] as DocumentReference,
      driveName: json['driveName'],
      description: json['description'],
      photos: List<String>.from(json['photos']),
      
    );
  }

  static List<DriveModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<DriveModel>((dynamic json) => DriveModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson(DriveModel driveModel) {
    return {
      'driveId': driveId,
      'donations': donations.map((donation) => donation).toList(), 
      'organization': organization,
      'driveName': driveName,
      'description': description,
      'photos': photos,
    };
  }
}