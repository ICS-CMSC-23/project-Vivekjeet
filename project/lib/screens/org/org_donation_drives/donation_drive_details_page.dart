import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../providers/drive_provider.dart';
import 'edit_donation_drive_page.dart';

class DonationDriveDetailsPage extends StatefulWidget {
  final String driveId;
  final String driveName;
  final String imageUrl;
  final String description;
  final List<dynamic> donations;
  final List<String> photos;

  const DonationDriveDetailsPage({
    Key? key,
    required this.driveId,
    required this.driveName,
    required this.imageUrl,
    required this.description,
    required this.donations,
    required this.photos,
  }) : super(key: key);

  @override
  _DonationDriveDetailsPageState createState() =>
      _DonationDriveDetailsPageState();
}

class _DonationDriveDetailsPageState extends State<DonationDriveDetailsPage> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> driveData;
  final User? user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

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
    _tabController = TabController(length: 2, vsync: this);
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
                      Tab(text: 'Donations'),
                      Tab(text: 'Photos'),
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
    return ListView(
      shrinkWrap: true,
      children: [
        const Text(
          'Donations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.donations.map<Widget>((donation) {
          return Text(
            donation.toString(),
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          );
        }).toList(),
      ],
    );
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
}
