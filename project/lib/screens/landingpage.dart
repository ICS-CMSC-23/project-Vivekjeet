import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screens/splashscreen.dart';
import 'admin_homepage.dart';
import 'donor/donor_homepage.dart';
import 'login.dart';
import 'org/org_homepage.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData) {
            return UserHomepage(user: snapshot.data!);
          } else {
            return const SplashScreen();
          }
        }
      },
    );
  }
}

class UserHomepage extends StatelessWidget {
  final User user;

  UserHomepage({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            var userType = snapshot.data!['type'];
            return _buildHomepageWidget(context, userType);
          } else {
            return const Text('Error fetching user data');
          }
        }
      },
    );
  }

  Widget _buildHomepageWidget(BuildContext context, String userType) {
    Navigator.pop(context);
    switch (userType) {
      case 'Donor':
        return const DonorHomepage();
      case 'Organization':
        return const OrgHomepage();
      case 'Admin':
        return const AdminHomepage();
      default:
        return const Text('Invalid user type');
    }
  }
}
