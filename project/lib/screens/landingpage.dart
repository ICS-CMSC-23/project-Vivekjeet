import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import './login.dart';
import 'admin_homepage.dart';
import 'donor/donor_homepage.dart';
import 'org/org_homepage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String userType = '';
  @override
  Widget build(BuildContext context) {
    Stream<User?> userStream = context.watch<MyAuthProvider>().userStream;
    
    return StreamBuilder<User?>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData) {
          return const LoginPage();
        }
        return DonorHomepage();

        // final currentUser = context.watch<UsersProvider>().details;
        // userType = currentUser['type'];

        // User? user = FirebaseAuth.instance.currentUser;
        // DocumentSnapshot<Map<String, dynamic>> snap = FirebaseFirestore.instance.collection('Users').doc(user?.uid).get() as DocumentSnapshot<Map<String, dynamic>>;
        // userType = snap['type'];
        

        // switch (userType) {
        //   case 'Donor':
        //     return const DonorHomepage();
        //   case 'Organization':
        //     return const OrgHomepage();
        //   case 'Admin':
        //     return const AdminHomepage();
        //   default:
        //     return const LoginPage()
        // }
      },
    );
  }
}