import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  String? donationId;
  DocumentReference donor;
  DocumentReference organization;
  String category;
  double weight;
  String? photo;
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
    required this.category,
    required this.weight,
    required this.isPickup,
    this.addresses,
    this.photo,
    this.contactNumber,
    required this.schedule,
    required this.status,
    required this.qrCode

  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      donationId: json['donationId'],
      donor: FirebaseFirestore.instance.doc(json['donor']),
      organization: FirebaseFirestore.instance.doc(json['organization']),
      category: json['category'],
      weight: json['weight'].toDouble(),
      photo: json['photo'],
      isPickup: json['isPickup'],
      addresses: json['addresses'] != null ? List<String>.from(json['addresses']) : null,
      contactNumber: json['contactNumber'],
      schedule: DateTime.parse(json['schedule']),
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
      'donor': donor.path,
      'organization': organization.path,
      'category': category,
      'weight': weight,
      'photo': photo,
      'isPickup': isPickup,
      'addresses': addresses,
      'contactNumber': contactNumber,
      'schedule': schedule,
      'status': status,
      'qrCode': qrCode,
    };
  }
}