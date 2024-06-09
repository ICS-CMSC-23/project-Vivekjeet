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

  final List<Widget> _pages = [
    const DonationsPage(),
    const QRCodeScanPage(),
    const DonationDrivesPage(),
    const OrgProfilePage(),
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
        title: const Text("Elbiyaya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 32),),
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
          GButton(icon: Icons.qr_code_scanner, text: 'Scan QR'), // New tab
          GButton(icon: Icons.drive_eta, text: 'Drives'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

class DonationsPage extends StatefulWidget {
  const DonationsPage({Key? key}) : super(key: key);

  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  @override
  Widget build(BuildContext context) {
    // Access the current user's organization ID
    DocumentReference orgRef = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');

    // Stream of donations filtered by organization reference
    Stream<QuerySnapshot> donationsStream = FirebaseFirestore.instance
        .collection('donations')
        .where('organization', isEqualTo: orgRef)
        .snapshots();

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
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No available donations.',
              style: TextStyle(fontSize: 20, color: Colors.pink),
            ),
          );
        } else {
          return GridView.builder(
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
                            offset: Offset(0, 0),
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
                                  donorData['userName'], // Display donor's name
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  donation.status
                                ),
                                donation.isPickup
                                ? const Text(
                                  'Pickup'
                                )
                                : const Text(
                                  'Drop off'
                                )
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
          );
        }
      },
    );
  }
}

class QRCodeScanPage extends StatefulWidget {
  const QRCodeScanPage({Key? key}) : super(key: key);

  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  String _scanResult = '';

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
    (donationSnapshot.data() ?? {}) as Map<String, dynamic>);

        DocumentReference donorRef = donationSnapshot['donor'];

        DocumentSnapshot donorSnapshot = await donorRef.get();

        if (donorSnapshot.exists) {
          Map<String, dynamic> donorData = donorSnapshot.data() as Map<String, dynamic>;

          context.read<DonationsProvider>().updateStatus(donation.donationId, 'Completed');
          donation.status = 'Completed';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailsPage(donation: donation, donorData: donorData),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_scanResult.isNotEmpty)
              Text(
                'Scan Result: $_scanResult',
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanQRCode,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(
                  const Color(0xFF618264),
                ),
              ),
              child: const Text('Scan Donation', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}