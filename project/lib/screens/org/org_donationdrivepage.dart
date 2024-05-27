import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonationDrivesPage extends StatefulWidget {
  const DonationDrivesPage({super.key});

  @override
  _DonationDrivesPageState createState() => _DonationDrivesPageState();
}

class _DonationDrivesPageState extends State<DonationDrivesPage> {
  @override
  //creating for donors homepage
  Widget build(BuildContext context) {
    DocumentReference orgRef = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("donationDrives")
                .where('organization', isEqualTo: orgRef)
                .snapshots(),
      builder: (BuildContext context, snapshot) {
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
              style: TextStyle(fontSize: 20, color: Colors.pink),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final driveData = snapshot.data?.docs[index].data() as Map<String, dynamic>;
              final DocumentReference organizationRef = driveData['organization'];
              return FutureBuilder<DocumentSnapshot>(
                future: organizationRef.get(),
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
                  
                  return ListTile(
                    title: Text(driveData['driveName']),
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
