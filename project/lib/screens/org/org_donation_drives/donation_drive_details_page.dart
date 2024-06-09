import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import '../../../models/donation_model.dart';
import '../../../providers/drive_provider.dart';
import '../donation_details_page.dart';
import 'edit_donation_drive_page.dart';

class DonationDriveDetailsPage extends StatefulWidget {
  final String driveId;
  final String driveName;
  final String imageUrl;
  final String description;
  final List<dynamic> donations;
  final List<String> photos;
  final QueryDocumentSnapshot drive;


  const DonationDriveDetailsPage({
    Key? key,
    required this.driveId,
    required this.driveName,
    required this.imageUrl,
    required this.description,
    required this.donations,
    required this.photos,
    required this.drive
  }) : super(key: key);

  @override
  _DonationDriveDetailsPageState createState() =>
      _DonationDriveDetailsPageState();
}

class _DonationDriveDetailsPageState extends State<DonationDriveDetailsPage> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> driveData;
  final User? user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    driveData = {
      'driveName': widget.driveName,
      'imageUrl': widget.imageUrl,
      'description': widget.description,
      'donations': widget.donations,
      'photos': widget.photos,
    };
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF618264),
              Color(0xFFB0D9B1),
              Color(0xFFB0D9B1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            // Header
            header(context),
            // Profile Picture
            profilePicture(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  driveDetails(context),
                  const Divider(),
                  aboutSection(),
                  const Divider(),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF618264),
                    labelColor: const Color(0xFF618264),
                    unselectedLabelColor: Colors.black54,
                    tabs: const [
                      Tab(text: 'Inventory'),
                      Tab(text: 'Photos'),
                      Tab(text: 'Donations')
                    ],
                  ),
                  // Tab Bar View
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        donationDetails(),
                        photosView(),
                        otherDonations()
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text('Are you sure you want to delete this donation drive?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    context.read<DriveProvider>().deleteDrive(widget.driveId, widget.photos);
                                    if (context.mounted) Navigator.of(context).pop();
                                    if (context.mounted) Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF618264),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Delete Drive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profilePicture() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB0D9B1),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/temppfp.jpg',
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Text(
            'Donation Drive Details',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDonationDrivePage(
                    driveId: widget.driveId,
                    initialDriveName: widget.driveName,
                    initialDescription: widget.description,
                    initialPhotos: widget.photos,
                  ),
                ),
              );
              if(context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget driveDetails(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.driveName,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                'Donations: ${widget.donations.length}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget aboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this drive',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

Widget donationDetails() {
  return widget.donations.isEmpty
      ? const Center(child: Text('No donations yet.'))
      : ListView.builder(
          shrinkWrap: true,
          itemCount: widget.donations.length,
          itemBuilder: (BuildContext context, int index) {
            final donationRef = widget.donations[index];
            
            return StreamBuilder<DocumentSnapshot>(
              stream: donationRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No data available.'));
                }

                final donationData = snapshot.data!.data() as Map<String, dynamic>;
                final donation = DonationModel.fromJson(donationData);

                return FutureBuilder<DocumentSnapshot>(
                  future: donationData['donor'].get(),
                  builder: (context, donorSnapshot) {
                    if (donorSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (donorSnapshot.hasError) {
                      return Center(child: Text('Error: ${donorSnapshot.error}'));
                    }
                    if (!donorSnapshot.hasData || donorSnapshot.data == null) {
                      return const Center(child: Text('No donor data available.'));
                    }

                    final donorData = donorSnapshot.data!.data() as Map<String, dynamic>;
                    return buildDonationTile(donation, donationData, donorData, index);
                  },
                );
              },
            );
          },
        );
}

Widget buildDonationTile(DonationModel donation, Map<String, dynamic> donationData, Map<String, dynamic> donorData, int index) {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFD0E7D2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            donationData['categories'].join(', '),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: buildDonationDetails(donationData, donorData),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => removeDonation(donationData, index),
          ),
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
        ),
      ),
    ],
  );
}

Widget buildDonationDetails(Map<String, dynamic> donationData, Map<String, dynamic> donorData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Donor: ${donorData['userName']}'),
      Text('Status: ${donationData['status']}'),
      Text('Pickup: ${donationData['isPickup'] ? 'Yes' : 'No'}'),
      Text('Weight: ${donationData['weightValue']} ${donationData['weightUnit']}'),
      Text('Scheduled: ${DateFormat('yyyy-MM-dd hh:mm a').format((donationData['schedule'] as Timestamp).toDate())}'),
      if (donationData['addresses'] != null && donationData['addresses'].isNotEmpty)
        Text('Addresses: ${donationData['addresses'].join(', ')}'),
      if (donationData['contactNumber'] != null)
        Text('Contact Number: ${donationData['contactNumber']}'),
    ],
  );
}

Future<void> removeDonation(Map<String, dynamic> donationData, int index) async {
  bool confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Removal'),
        content: const Text('Are you sure you want to remove this donation?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false if user cancels
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true if user confirms
            },
            child: const Text('Remove', style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    setState(() {
      widget.donations.removeAt(index);
    });

    await context.read<DriveProvider>().removeDonationFromDrive(widget.driveId, donationData['donationId']);
    FirebaseFirestore.instance.collection('donations').doc(donationData['donationId']).update({'donationDrive': null});
  }
}




  Widget photosView() {
    return GridView.builder(
      itemCount: widget.photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Image.network(
          widget.photos[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
  
  Widget otherDonations() {
  Stream<QuerySnapshot> donationsNoDriveStream = context.watch<DonationsProvider>().donationsWithNoDrives;
  return StreamBuilder<QuerySnapshot>(
    stream: donationsNoDriveStream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No donations without a drive.'));
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (BuildContext context, int index) {
          final donationDoc = snapshot.data!.docs[index];
          final donationData = donationDoc.data() as Map<String, dynamic>;
          DonationModel donation = DonationModel.fromJson(donationData);

          return FutureBuilder<DocumentSnapshot>(
            future: donationData['donor'].get(),
            builder: (context, donorSnapshot) {
              if (donorSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (donorSnapshot.hasError) {
                return Center(child: Text('Error: ${donorSnapshot.error}'));
              }
              if (!donorSnapshot.hasData || !donorSnapshot.data!.exists) {
                return const Center(child: Text('Donor not found.'));
              }

              final donorData = donorSnapshot.data!.data() as Map<String, dynamic>;
              return buildOtherDonationTile(donation, donationData, donorData);
            },
          );
        },
      );
    },
  );
}

Widget buildOtherDonationTile(DonationModel donation, Map<String, dynamic> donationData, Map<String, dynamic> donorData) {
  return Column(
    children: [
      donationData['donationDrive'] == null
      ? Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFD0E7D2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            donationData['categories'].join(', '),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: buildDonationDetails(donationData, donorData),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () => addDonationToDrive(donationData, donorData),
          ),
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
        ),
      )
      : Container()
    ],
  );
}

Future<void> addDonationToDrive(Map<String, dynamic> donationData, Map<String, dynamic> donorData) async {
  bool confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Addition'),
        content: const Text('Add this donation to the drive?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false if user cancels
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true if user confirms
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );

  if (confirm == true && donationData['status'] == "Completed") {
    setState(() {
      // Add any state update logic here if necessary
    });

    await context.read<DriveProvider>().addDonationToDrive(widget.driveId, donationData['donationId']);
    await context.read<DonationsProvider>().addDrive(donationData['donationId'], widget.driveId);
    String message = "Hello, ${donorData['userName']}! Your donation has been assigned to ${widget.driveName}.";                      
    try {
      telephony.sendSms(
        to: donorData['contactNumber'],
        message: message.trim(),
      );
    } catch (e) {
      print("Error: $e");
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please mark the donation as completed first.'),
      ),
    );
  }
}

}
