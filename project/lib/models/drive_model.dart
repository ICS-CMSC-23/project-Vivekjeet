import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriveModel {
  String? driveId;
  List<DocumentReference> donations;
  DocumentReference organization;
  String name;
  String description;
  List<String> photos;

  DriveModel({
    this.driveId,
    required this.donations,
    required this.organization,
    required this.name,
    required this.description,
    required this.photos
  });

  factory DriveModel.fromJson(Map<String, dynamic> json) {
    return DriveModel(
      driveId: json['driveId'],
      donations: List<DocumentReference>.from(json['donations']),
      organization: json['organization'] as DocumentReference,
      name: json['name'],
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
      'donations': donations.map((donation) => donation.path).toList(),
      'organization': organization.path,
      'name': name,
      'description': description,
      'photos': photos,
    };
  }
}