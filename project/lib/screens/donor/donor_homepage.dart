import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../providers/auth_provider.dart';
import '../login.dart';
import 'donor_orglist.dart';
import 'donor_profile.dart';
import '../constants.dart';
import 'donor_donations.dart';

class DonorHomepage extends StatefulWidget {
  const DonorHomepage({super.key});

  @override
  State<DonorHomepage> createState() => _DonorHomepageState();
}

class _DonorHomepageState extends State<DonorHomepage> {
  //data initializations for navbar widget

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DonorOrgsList(),
    const DonorDonations(),
    const DonorProfile(),
  ];

  final List<String> titleList = [
    'Home',
    'Donations',
    'Profile',
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

        return displayDonorHomepage(context);
      },
    );
  }

  Scaffold displayDonorHomepage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          titleList[_selectedIndex],
          style: TextStyle(
            color: Constants.blackColor,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
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
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.drive_eta, text: 'Drives'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}
