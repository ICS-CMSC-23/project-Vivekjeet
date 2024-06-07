import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/org/org_donation_drives/add_donation_drive_page.dart';

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
                    driveName: driveData['driveName'],
                    description: driveData['description'],
                    imageUrl: driveData['photos'].isNotEmpty ? driveData['photos'][0] : '',
                    donations: driveData['donations'],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDonationDrivePage(),
              )
            );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DonationDriveCard extends StatelessWidget {
  final String driveName;
  final String description;
  final String imageUrl;
  final List<dynamic> donations;

  DonationDriveCard({
    required this.driveName,
    required this.description,
    required this.imageUrl,
    required this.donations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                        
                          },
                          icon: const Icon(Icons.edit, size: 20,),
                        ),
                        IconButton(
                          onPressed: () {
                        
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
    );
  }
}
