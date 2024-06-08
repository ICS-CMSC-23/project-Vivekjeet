import 'package:flutter/material.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../../providers/user_provider.dart';

class DonorDonations extends StatefulWidget {
  const DonorDonations({super.key});
  @override
  _DonorDonationsState createState() => _DonorDonationsState();
}

class _DonorDonationsState extends State<DonorDonations> {
  @override
  void initState() {
    super.initState();
    final donorId = FirebaseAuth.instance.currentUser?.uid;
    if (donorId != null) {
      Provider.of<DonationsProvider>(context, listen: false).fetchDonationsByDonor(donorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: listDonations(context),
            ),
          ],
        ),
      ),
    );
  }
}

Widget listDonations(BuildContext context) {
  Stream<QuerySnapshot> donationsStream =
      context.watch<DonationsProvider>().donorDonations;

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
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('No donations found.',
                style: TextStyle(fontSize: 20, color: Colors.pink)),
          ],
        );
      } else {
        return ListView.builder(
          itemCount: snapshot.data?.docs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: ((context, index) {
            Map<String, dynamic> donation = snapshot.data?.docs[index].data() as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              key: Key(snapshot.data!.docs[index].id),
              child: ListTile(
                leading: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.black54,
                  size: 50,
                ),
                title: Text(
                  donation['categories'].join(', '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('Donation to: ${orgName}'),
                    Text('Status: ${donation['status']}'),
                    Text('Pickup: ${donation['isPickup'] ? 'Yes' : 'No'}'),
                    Text('Weight: ${donation['weightValue']} ${donation['weightUnit']}'),
                    Text('Scheduled: ${DateFormat('yyyy-MM-dd hh:mm a').format((donation['schedule'] as Timestamp).toDate())}'),
                    if (donation['addresses'] != null) Text('Addresses: ${donation['addresses'].join(', ')}'),
                    if (donation['contactNumber'] != null) Text('Contact Number: ${donation['contactNumber']}'),
                  ],
                ),
                tileColor: Constants.primaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onTap: () {
                  // Actions when tapped, maybe view detailed page
                },
              ),
            );
          }),
        );
      }
    },
  );
}