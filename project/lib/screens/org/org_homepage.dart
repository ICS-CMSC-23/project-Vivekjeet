import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:project/models/donation_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/drive_provider.dart';
import 'org_donationdrivepage.dart';
import 'org_profile.dart';


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

  @override
  //creating for donors homepage
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> donationsStream = context.watch<DonationsProvider>().donations;
    return StreamBuilder<QuerySnapshot>(
    stream: donationsStream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Error encountered! ${snapshot.error}"),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
          // ignore: avoid_print
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        // Check if snapshot has no data or if docs is empty
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('No available donations.',
                style: TextStyle(fontSize: 20, color: Colors.pink)),
            // Text (snapshot.data!.docs.toString()),
          ],
        );
      } else {
        // If snapshot has data and docs is not empty
        return ListView.builder(
          itemCount: snapshot.data?.docs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: ((context, index) {
            DonationModel donation = DonationModel.fromJson(snapshot.data?.docs[index].data() as Map<String, dynamic>);
            return Container(
              child: Text(donation.category)
               
            );
          
            
          }),
        );
      }
    },
  );
}}