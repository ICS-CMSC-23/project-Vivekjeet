import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../apis/firebase_donation_api.dart';
import '../models/donation_model.dart';

class DonationsProvider with ChangeNotifier {
  late FirebaseDonationAPI firebaseService;
  late DocumentSnapshot _selectedDonationStream;
  late Stream<QuerySnapshot> _donationsStream;
  late Stream<QuerySnapshot> _donorDonationsStream;
  late Stream<QuerySnapshot> _organizationDonationsStream;
  late Stream<QuerySnapshot> _donorOrganizationDonationsStream;
  late Stream<QuerySnapshot> _noDriveDonationsStream;

  DonationsProvider() {
    firebaseService = FirebaseDonationAPI();
    _donationsStream = firebaseService.getDonations();
    fetchDonationsWithNoDrive();
  }

  DocumentSnapshot<Object?> get selectedDonation => _selectedDonationStream;
  Stream<QuerySnapshot> get donations => _donationsStream;
  Stream<QuerySnapshot> get donorDonations => _donorDonationsStream;
  Stream<QuerySnapshot> get organizationDonations => _organizationDonationsStream;
  Stream<QuerySnapshot> get donorOrganizationDonations => _donorOrganizationDonationsStream;
  Stream<QuerySnapshot> get donationsWithNoDrives => _noDriveDonationsStream;

  void fetchDonationById(String donationId) async {
    _selectedDonationStream = await firebaseService.getDonationById(donationId);
    notifyListeners();
  }

  void fetchDonations() {
    _donationsStream = firebaseService.getDonations();
    notifyListeners();
  }

  void fetchDonationsByDonor(String donorId) {
    _donorDonationsStream = firebaseService.getDonationsByDonor(donorId);
    notifyListeners();
  }

  void fetchDonationsByDonorToOrganization(String donorId, String orgId) {
    _donorOrganizationDonationsStream = firebaseService.getDonationsByDonorToOrganization(donorId, orgId);
    notifyListeners();
  }

  void fetchDonationsOfOrganization(String orgId) {
    _organizationDonationsStream = firebaseService.getDonationsOfOrganization(orgId);
    notifyListeners();
  }

  Future<void> addDonation(DonationModel donation, List<File>? photos) async {
    String message = await firebaseService.addDonation(donation.toJson(donation), photos);
    notifyListeners();
    print(message);
  }

  void deleteDonation(String donationId) async {
    String message = await firebaseService.deleteDonation(donationId);
    print(message);
    notifyListeners();
  }

  Future<void> updateStatus(String? donationId, String newStatus) async {
    await firebaseService.updateStatus(donationId, newStatus);
    notifyListeners();
  }

  Future<void> removeDrive(String? donationId) async {
    await firebaseService.removeDrive(donationId);
    notifyListeners();
  }

  Future<void> addDrive(String? donationId, String driveId) async {
    await firebaseService.addDrive(donationId, driveId);
    notifyListeners();
  }

  void fetchDonationsWithNoDrive(){
    _noDriveDonationsStream = firebaseService.getDonationsWithNoDrive();
    notifyListeners();
  }
}