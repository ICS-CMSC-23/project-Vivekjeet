import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:project/models/donation_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import 'donation_details_page.dart';
import 'org_donation_drives/org_donationdrivepage.dart';
import 'org_profile.dart';

class OrgHomepage extends StatefulWidget {
  const OrgHomepage({super.key});
  @override
  _OrgHomepageState createState() => _OrgHomepageState();
}

class _OrgHomepageState extends State<OrgHomepage> {
  int _selectedIndex = 0;
  String _scanResult = '';

  final List<Widget> _pages = [
    const DonationsPage(),
    const PlaceholderWidget(), // Placeholder for QR code scanning
    const DonationDrivesPage(),
    const OrgProfilePage(),
  ];

  Future<void> _scanQRCode() async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 
        'Cancel', 
        true, 
        ScanMode.QR,
      );
      if (!mounted) return;

      DocumentSnapshot donationSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .doc(scanResult)
          .get();

      if (donationSnapshot.exists) {
        DonationModel donation = DonationModel.fromJson(
          (donationSnapshot.data() ?? {}) as Map<String, dynamic>
        );

        DocumentReference donorRef = donationSnapshot['donor'];

        DocumentSnapshot donorSnapshot = await donorRef.get();

        if (donorSnapshot.exists) {
          Map<String, dynamic> donorData = donorSnapshot.data() as Map<String, dynamic>;

          context.read<DonationsProvider>().updateStatus(donation.donationId, 'Completed');
          donation.status = 'Completed';

          // Navigate to DonationDetailsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailsPage(
                donation: donation,
                donorData: donorData,
              ),
            ),
          );
        } else {
          setState(() {
            _scanResult = 'Donor data not found';
          });
        }
      } else {
        setState(() {
          _scanResult = 'Donation not found';
        });
      }
    } on PlatformException {
      _scanResult = 'Failed to get platform version.';
    }
  }

  void _onTabChange(int index) {
    if (index == 1) { // Check if the selected tab is the "Scan QR" tab
      _scanQRCode();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
        title: const Text("Elbiyaya", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF618264), fontSize: 32),),
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
        gap: 0,
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
        onTabChange: _onTabChange,
        tabs: const [
          GButton(icon: Icons.home, text: 'Donations'),
          GButton(icon: Icons.qr_code_scanner, text: 'Scan QR'), // QR scan tab
          GButton(icon: Icons.drive_eta, text: 'Drives'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class DonationsPage extends StatefulWidget {
  const DonationsPage({Key? key}) : super(key: key);

  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  String _selectedStatus = 'All';

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Scheduled for Pick-up',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    DocumentReference orgRef = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');

    // Stream of donations filtered by organization reference and selected status
    Stream<QuerySnapshot> donationsStream = FirebaseFirestore.instance
        .collection('donations')
        .where('organization', isEqualTo: orgRef)
        .where('status', isEqualTo: _selectedStatus == 'All' ? null : _selectedStatus)
        .snapshots();

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No available donations.',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    GridView.builder(
                      itemCount: snapshot.data!.docs.length,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                      ),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DonationModel donation = DonationModel.fromJson(
                            snapshot.data!.docs[index].data() as Map<String, dynamic>);
                    
                        // Fetch donor data using the donor reference
                        return StreamBuilder<DocumentSnapshot>(
                          stream: (donation.donor).snapshots(),
                          builder: (context, donorSnapshot) {
                            if (donorSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (donorSnapshot.hasError) {
                              return Center(child: Text("Error: ${donorSnapshot.error}"));
                            }
                            if (!donorSnapshot.hasData || !donorSnapshot.data!.exists) {
                              return const Center(child: Text("Donor not found"));
                            }
                    
                            final donorData = donorSnapshot.data!.data() as Map<String, dynamic>;
                    
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DonationDetailsPage(
                                      donation: donation,
                                      donorData: donorData,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFFB0D9B1),
                                      blurRadius: 15,
                                      offset: Offset(10, 10),
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: Container(
                                        margin: const EdgeInsets.all(2),
                                        child: donation.photos == null || donation.photos!.isEmpty
                                            ? Image.asset(
                                                'images/login_logo.png',
                                                height: 100,
                                                width: 120,
                                                fit: BoxFit.fill,
                                              )
                                            : Image.network(
                                                donation.photos![0],
                                                height: 100,
                                                width: 120,
                                              ),
                                      ),
                                    ),
                                    const Divider(),
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            donorData['userName'], 
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Status: ${donation.status}', style: const TextStyle(fontSize: 12),),
                                          donation.isPickup
                                              ? const Text('Mode: Pickup', style: TextStyle(fontSize: 12))
                                              : const Text('Mode: Drop off', style: TextStyle(fontSize: 12))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(200, 255, 255, 255), 
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2), 
                                blurRadius: 10, 
                                offset: const Offset(0, 5), 
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue!;
                                });
                              },
                              items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              dropdownColor: const Color.fromARGB(200, 255, 255, 255), 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}


