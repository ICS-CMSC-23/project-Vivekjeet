import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../apis/firebase_donation_api.dart';
import '../models/donation_model.dart';

class DonationsProvider with ChangeNotifier {
  late FirebaseDonationAPI firebaseService;
  late DocumentSnapshot _selectedDonationStream;
  late Stream<QuerySnapshot> _donationsStream;
  late Stream<QuerySnapshot> _organizationDonationsStream;

  DonationsProvider() {
    firebaseService = FirebaseDonationAPI();
    _donationsStream = firebaseService.getDonations();
  }

  Stream<DocumentSnapshot> get selectedDonation => _selectedDonationStream;
  Stream<QuerySnapshot> get donations => _donationsStream;
  Stream<QuerySnapshot> get organizationDonations => _organizationDonationsStream;

  void fetchDonationById(String donationId) async {
    _selectedDonation = await firebaseService.getDonationById(donationId);
    notifyListeners();
  }

  void fetchDonations() {
    _donationsStream = firebaseService.getDonations();
    notifyListeners();
  }

  void fetchDonationsOfOrganization(String orgId) {
    _organizationDonationsStream = firebaseService.getDonationsOfOrganization(orgId);
    notifyListeners();
  }

  void addDonation(DonationModel donation) async {
    String message = await firebaseService.addDonation(donation.toJson(donation));
    notifyListeners(); 
    print(message);
  }

  void deleteDonation(String donationId) async {
    String message = await firebaseService.deleteDonation(donationId);
    print(message);
    notifyListeners();
  }
}