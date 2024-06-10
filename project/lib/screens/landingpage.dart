import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/screens/splashscreen.dart';
import 'package:provider/provider.dart';
import 'admin/admin_homepage.dart';
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            var userType = snapshot.data!['type'];
            if (userType == 'Organization') {
              return _buildHomepageWidget(context, userType,
                  status: snapshot.data!['isApproved']);
            }
            return _buildHomepageWidget(context, userType);
          } else {
            return const Text('Error fetching user data');
          }
        }
      },
    );
  }

  Widget _buildHomepageWidget(BuildContext context, String userType,
      {bool? status}) {
    switch (userType) {
      case 'Donor':
        return const DonorHomepage();
      case 'Organization':
        if (status == null) {
          return Center(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Your account is queued for approval.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF00371D),
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    child: const Text('Back',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                  )
                ],
              ),
            ),
          );
        } else if (status == false) {
          return Center(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Your account has been disapproved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF00371D),
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    child: const Text('Back',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                  )
                ],
              ),
            ),
          );
        } else {
          return const OrgHomepage();
        }
      case 'Admin':
        return const AdminHomePage();
      default:
        return const Text('Invalid user type');
    }
  }
}
