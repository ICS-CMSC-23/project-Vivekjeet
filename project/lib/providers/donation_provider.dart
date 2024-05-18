import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../apis/firebase_donation_api.dart';
import '../models/donation_model.dart';

class DonationsProvider with ChangeNotifier {
  late FirebaseDonationAPI firebaseService;
  late Stream<QuerySnapshot> _donationsStream;

  DonationsProvider() {
    firebaseService = FirebaseDonationAPI();
    _donationsStream = firebaseService.getDonations();
  }

  Stream<QuerySnapshot> get donations => _donationsStream;

  void loadDonations() {
    _donationsStream = firebaseService.getDonations();
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