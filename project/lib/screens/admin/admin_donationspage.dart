import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/models/donation_model.dart';

class AdminDonationsPage extends StatefulWidget {
  const AdminDonationsPage({super.key});
  @override
  State<AdminDonationsPage> createState() => _AdminDonationsPageState();
}

class _AdminDonationsPageState extends State<AdminDonationsPage> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> donationsStream =
        context.watch<DonationsProvider>().organizationDonations;
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        toolbarHeight: 75,
        iconTheme: const IconThemeData(
          color: Color(0xFF00371D),
          size: 28,
        ),
        title: const Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Donations List",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color(0xFF00371D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Administrator",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFF2F8F2), // Adjust border color if needed
            width: 1.0, // Adjust border width if needed
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<MyAuthProvider>().signOut();
              },
            ),
          ),
        ],
      ),
      body: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                // alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                child: const Text(
                  "Donations",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xFF00371D),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  height: MediaQuery.of(context).size.height * 0.7,
                  // color: Colors.blue,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: donationsStream,
                      builder: (context, snapshot) {
                        List<dynamic> donors = snapshot.data?.docs ?? [];
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error encountered! ${snapshot.error}"),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00371D)))),
                          );
                        } else if (!snapshot.hasData || donors.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: Center(
                              child: Text(
                                "No donation data available",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF00371D),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              DonationModel currentDonation =
                                  DonationModel.fromJson(
                                      snapshot.data?.docs[index].data()
                                          as Map<String, dynamic>);
                              return Container(
                                  child: ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Donation id:\n${currentDonation.donationId}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color(0xFF00371D),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      currentDonation.isPickup
                                          ? 'Pickup date: ${currentDonation.schedule}'
                                          : 'Dropoff date: ${currentDonation.schedule}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  children: <Widget>[
                                    Text(
                                      '${double.parse(currentDonation.weightValue.toStringAsFixed(2))}${currentDonation.weightUnit}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color(0xFF00371D),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ));
                            });
                      }))
            ],
          )),
    );
  }
}
