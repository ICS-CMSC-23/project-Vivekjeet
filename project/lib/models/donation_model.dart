import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  String? donationId;
  DocumentReference donor;
  DocumentReference organization;
  List<String> categories;
  double weightValue;
  String weightUnit;
  List<String>? photos;
  bool isPickup;
  List<String>? addresses;
  String? contactNumber;
  DateTime schedule;
  String status;
  String qrCode;

  DonationModel({
    this.donationId,
    required this.donor,
    required this.organization,
    required this.categories,
    required this.weightValue,
    required this.weightUnit,
    required this.isPickup,
    this.addresses,
    this.photos,
    this.contactNumber,
    required this.schedule,
    required this.status,
    required this.qrCode
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      donationId: json['donationId'],
      donor: json['donor'] as DocumentReference,
      organization: json['organization'] as DocumentReference,
      categories: List<String>.from(json['categories']),
      weightValue: json['weightValue'].toDouble(),
      weightUnit: json['weightUnit'],
      photos: List<String>.from(json['photos']),
      isPickup: json['isPickup'],
      addresses: json['addresses'] != null ? List<String>.from(json['addresses']) : null,
      contactNumber: json['contactNumber'],
      schedule: (json['schedule'] as Timestamp).toDate(),
      status: json['status'],
      qrCode: json['qrCode'],
    );
  }

  static List<DonationModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<DonationModel>((dynamic json) => DonationModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson(DonationModel donationModel) {
    return {
      'donationId': donationId,
      'donor': donor,
      'organization': organization,
      'categories': categories,
      'weightValue': weightValue,
      'weightUnit': weightUnit,
      'photos': photos,
      'isPickup': isPickup,
      'addresses': addresses,
      'contactNumber': contactNumber,
      'schedule': Timestamp.fromDate(schedule),
      'status': status,
      'qrCode': qrCode,
    };
  }
}