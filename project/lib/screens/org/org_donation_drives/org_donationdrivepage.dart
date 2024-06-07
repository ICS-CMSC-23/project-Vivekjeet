import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/org/org_donation_drives/add_donation_drive_page.dart';
import 'package:provider/provider.dart';

import '../../../providers/drive_provider.dart';
import 'donation_drive_details_page.dart';
import 'edit_donation_drive_page.dart';

class DonationDrivesPage extends StatefulWidget {
  const DonationDrivesPage({Key? key}) : super(key: key);

  @override
  _DonationDrivesPageState createState() => _DonationDrivesPageState();
}

class _DonationDrivesPageState extends State<DonationDrivesPage> {
  @override
  Widget build(BuildContext context) {
    DocumentReference orgRef = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("donationDrives")
            .where('organization', isEqualTo: orgRef)
            .snapshots(),
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
                'No available drives.',
                style: TextStyle(fontSize: 20, color: Color(0xFF618264)),
              ),
            );
          }
      
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final driveData = snapshot.data?.docs[index].data() as Map<String, dynamic>;
              final DocumentReference organizationRef = driveData['organization'];
      
              return StreamBuilder<DocumentSnapshot>(
                stream: organizationRef.snapshots(),
                builder: (context, organizationSnapshot) {
                  if (organizationSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (organizationSnapshot.hasError) {
                    return Text('Error: ${organizationSnapshot.error}');
                  }
                  if (!organizationSnapshot.hasData || !organizationSnapshot.data!.exists) {
                    return const Text('Organization not found');
                  }
      
                  final organizationData = organizationSnapshot.data!.data() as Map<String, dynamic>;
      
                  return DonationDriveCard(
                    driveId: snapshot.data!.docs[index].id,
                    driveName: driveData['driveName'],
                    description: driveData['description'],
                    imageUrl: driveData['photos'].isNotEmpty ? driveData['photos'][0] : '',
                    donations: driveData['donations'],
                    photos: driveData['photos'].cast<String>(),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDonationDrivePage(),
              )
            );
        },
        backgroundColor: const Color(0xFF618264),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DonationDriveCard extends StatelessWidget {
  final String driveId;
  final String driveName;
  final String description;
  final String imageUrl;
  final List<dynamic> donations;
  final List<String> photos;

  DonationDriveCard({
    required this.driveId,
    required this.driveName,
    required this.description,
    required this.imageUrl,
    required this.donations,
    required this.photos
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDriveDetailsPage(
              driveId: driveId,
              driveName: driveName,
              description: description,
              imageUrl: imageUrl,
              donations: donations,
              photos: photos,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(
              imageUrl
            ),
            fit:  BoxFit.cover
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFB0D9B1),
              blurRadius: 15,
              offset: Offset(0, 0),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(153, 255, 255, 255),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFB0D9B1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    )
                  ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driveName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.outbox),
                          Text(
                            ': ${donations.length}'
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditDonationDrivePage(
                                    driveId: driveId,
                                    initialDriveName: driveName,
                                    initialDescription: description,
                                    initialPhotos: photos,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 20,),
                          ),
                          IconButton(
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
                                          context.read<DriveProvider>().deleteDrive(driveId, photos);
                                          Navigator.of(context).pop();
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
                            icon: const Icon(Icons.delete, size: 20,),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
