import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:project/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login.dart';
import 'org_donationdrivepage.dart';
import 'org_profile.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../donor/donor_orglist.dart';

class OrgHomepage extends StatefulWidget {
  const OrgHomepage({super.key});
  @override
  _OrgHomepageState createState() => _OrgHomepageState();
}

class _OrgHomepageState extends State<OrgHomepage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DonationsPage(),
    const DonationDrivesPage(),
    const ProfilePage(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        }

        return displayOrgHomepage(context);
      },
    );
  }

  Scaffold displayOrgHomepage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ORG NAME"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<MyAuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: GNav(
        gap: 8,
        onTabChange: _onTabChange,
        tabs: const [
          GButton(icon: Icons.home, text: 'Donations'),
          GButton(icon: Icons.drive_eta, text: 'Drives'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});
  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  //creating for donors homepage
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Donations Page',
            style: TextStyle(fontSize: 24),
          ),
          ],
        
      ),
    );
  }
}


