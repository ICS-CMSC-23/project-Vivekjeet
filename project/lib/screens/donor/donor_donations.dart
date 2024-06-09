// import 'package:flutter/material.dart';
// import 'package:project/providers/donation_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import '../constants.dart';
// import '../../providers/user_provider.dart';

// class DonorDonations extends StatefulWidget {
//   const DonorDonations({super.key});
//   @override
//   _DonorDonationsState createState() => _DonorDonationsState();
// }

// class _DonorDonationsState extends State<DonorDonations> {
//   @override
//   void initState() {
//     super.initState();
//     final donorId = FirebaseAuth.instance.currentUser?.uid;
//     if (donorId != null) {
//       Provider.of<DonationsProvider>(context, listen: false).fetchDonationsByDonor(donorId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Expanded(
//               child: listDonations(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget listDonations(BuildContext context) {
//   Stream<QuerySnapshot> donationsStream =
//       context.watch<DonationsProvider>().donorDonations;

//   return StreamBuilder<QuerySnapshot>(
//     stream: donationsStream,
//     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//       if (snapshot.hasError) {
//         return Center(
//           child: Text("Error encountered! ${snapshot.error}"),
//         );
//       }
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       }
//       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//         return const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text('No donations found.',
//                 style: TextStyle(fontSize: 20, color: Colors.pink)),
//           ],
//         );
//       } else {
//         return ListView.builder(
//           itemCount: snapshot.data?.docs.length,
//           physics: const BouncingScrollPhysics(),
//           itemBuilder: ((context, index) {
//             Map<String, dynamic> donation = snapshot.data?.docs[index].data() as Map<String, dynamic>;
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               key: Key(snapshot.data!.docs[index].id),
//               child: ListTile(
//                 leading: const Icon(
//                   Icons.volunteer_activism,
//                   color: Colors.black54,
//                   size: 50,
//                 ),
//                 title: Text(
//                   donation['categories'].join(', '),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Text('Donation to: ${orgName}'),
//                     Text('Status: ${donation['status']}'),
//                     Text('Pickup: ${donation['isPickup'] ? 'Yes' : 'No'}'),
//                     Text('Weight: ${donation['weightValue']} ${donation['weightUnit']}'),
//                     Text('Scheduled: ${DateFormat('yyyy-MM-dd hh:mm a').format((donation['schedule'] as Timestamp).toDate())}'),
//                     if (donation['addresses'] != null) Text('Addresses: ${donation['addresses'].join(', ')}'),
//                     if (donation['contactNumber'] != null) Text('Contact Number: ${donation['contactNumber']}'),
//                   ],
//                 ),
//                 tileColor: Constants.primaryColor.withOpacity(0.6),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 onTap: () {
//                   // Actions when tapped, maybe view detailed page
//                 },
//               ),
//             );
//           }),
//         );
//       }
//     },
//   );
// }

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../../providers/user_provider.dart';
import '../constants.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
      Provider.of<DonationsProvider>(context, listen: false)
          .fetchDonationsByDonor(donorId);
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

  final Map<String, Icon> _categoryIcons = {
    'Food': Icon(Icons.fastfood, color: Constants.iconColor),
    'Clothes': Icon(Icons.checkroom, color: Constants.iconColor),
    'Cash': Icon(Icons.attach_money, color: Constants.iconColor),
    'Necessities': Icon(Icons.shopping_cart, color: Constants.iconColor),
  };

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
            bool _isCancelDisabled = false;

            if (donation['status'] == 'Confirmed' ||
                donation['status'] == 'Scheduled for Pick-up' ||
                donation['status'] == 'Completed' ||
                donation['status'] == 'Cancelled') _isCancelDisabled = true;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              key: Key(snapshot.data!.docs[index].id),
              child: ListTile(
                leading: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.black54,
                  size: 50,
                ),
                title: FutureBuilder<DocumentSnapshot>(
                  future: (donation['organization'] as DocumentReference).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading organization details...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ));
                    }
                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                      String organizationName = data['name'];
                      return Text(
                        "Donation to: $organizationName",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return Text(
                        "Organization details unavailable",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donation['categories'].join(', ')),
                    Text('Status: ${donation['status']}'),
                    // Text('Pickup: ${donation['isPickup'] ? 'Yes' : 'No'}'),
                    // Text(
                    //     'Weight: ${donation['weightValue']} ${donation['weightUnit']}'),
                    // Text(
                    //     'Scheduled: ${DateFormat('yyyy-MM-dd hh:mm a').format((donation['schedule'] as Timestamp).toDate())}'),
                    // if (donation['addresses'] != null)
                    //   Text('Addresses: ${donation['addresses'].join(', ')}'),
                    // if (donation['contactNumber'] != null)
                    //   Text('Contact Number: ${donation['contactNumber']}'),
                  ],
                ),
                tileColor: Constants.primaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.8,
                          minChildSize: 0.4,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) {
                            return SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<DocumentSnapshot>(
                                      future: (donation['organization'] as DocumentReference).get(),
                                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                          if (snapshot.hasData && snapshot.data!.exists) {
                                              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                              String organizationName = data['name'];
                                              return Text(organizationName,
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                  ));
                                          } else {
                                              return Text("Organization details unavailable",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                  ));
                                          }
                                      },
                                  ),
                                    SizedBox(height: 15),
                                    Text("Items to Donate:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Constants.primaryColor,
                                        )),
                                    SizedBox(height: 10),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Constants.primaryColor
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: _buildCategoryList(
                                          donation['categories'],
                                          _categoryIcons),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text("Donation Method:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Constants.primaryColor,
                                                  )),
                                              SizedBox(height: 10),
                                              if (donation['isPickup'])
                                                _buildDonationMethod('Pick up'),
                                              if (!donation['isPickup'])
                                                _buildDonationMethod(
                                                    'Drop off'),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text("Donation Weight:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Constants.primaryColor,
                                                  )),
                                              SizedBox(height: 10),
                                              _buildDonationWeight(
                                                  '${donation['weightValue']} ${donation['weightUnit']}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Scheduled Date:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Constants.primaryColor,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              _buildDonationDate(
                                                DateFormat('yyyy-MM-dd').format(
                                                    (donation['schedule']
                                                            as Timestamp)
                                                        .toDate()),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Scheduled Time:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Constants.primaryColor,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              _buildDonationTime(
                                                DateFormat('hh:mm a').format(
                                                    (donation['schedule']
                                                            as Timestamp)
                                                        .toDate()),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    if (donation['addresses'] != null &&
                                        donation['addresses'].isNotEmpty &&
                                        donation['contactNumber'] != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                //align center
                                                Text(
                                                  "Addresses:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Constants.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                _buildDonationAddress(
                                                    donation['addresses']
                                                        .join(', ')),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (donation['addresses'] != null &&
                                        donation['addresses'].isNotEmpty &&
                                        donation['contactNumber'] != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Contact Number:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Constants.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                _buildDonationContactNumber(
                                                    donation['contactNumber']),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Status:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Constants.primaryColor,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              _buildDonationStatus(
                                                  donation['status']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                         "Uploaded Photos:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.primaryColor,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(2),
                                      child: donation['photos'].isEmpty
                                          ? Text('No photo available')
                                          : Image.network(
                                              donation['photos'][0],
                                              height: 100,
                                              width: 120,
                                            ),
                                    ),
                                    if (donation['donationId'] != null &&
                                        !donation['isPickup'])
                                      Column(children: [
                                        Divider(
                                          color: Constants.blackColor.withOpacity(
                                              0.45), // Change the color to your desired divider color
                                          thickness:
                                              2.0, // Adjust the thickness of the divider
                                          height:
                                              20.0, // Adjust the height between the text and the divider
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'QR Code',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Constants.primaryColor),
                                        ),
                                        SizedBox(height: 20),
                                        _buildQRCodeGenerator(
                                            context, donation['donationId']),
                                        SizedBox(height: 30),
                                      ]),

                                    SizedBox(height: 20),
                                    if (donation['status'] == 'Completed' &&
                                        donation['proofs'].isNotEmpty)
                                      Column(
                                        children: [
                                          Text(
                                            "Proof of Donation:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Constants.primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            margin: const EdgeInsets.all(2),
                                            child: Image.network(
                                              donation['proofs'][0],
                                              height: 100,
                                              width: 120,
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                           onPressed: _isCancelDisabled
                                              ? null
                                              : () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Confirm Cancelation'),
                                                        content: Text(
                                                            'Are you sure you want to cancel this donation?'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: Text('No'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              // Perform cancellation and show Snackbar
                                                              context
                                                                  .read<
                                                                      DonationsProvider>()
                                                                  .updateStatus(
                                                                    donation[
                                                                        'donationId'],
                                                                    'Cancelled',
                                                                  );
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      'Donation cancelled'),
                                                                ),
                                                              );
                                                              _isCancelDisabled =
                                                                  true;
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: Text('Yes'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                          child: Text('Cancel Donate'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Back'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }),
        );
      }
    },
  );
}

Widget _buildCategoryList(
    List<dynamic> categories, Map<String, Icon> _categoryIcons) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: categories.map((category) {
      return Row(
        children: [
          _categoryIcons[category] ??
              Icon(
                Icons.more_horiz,
                color: Constants.iconColor,
              ), // Use the icon if available, otherwise use a default error icon
          SizedBox(width: 8), // Add spacing between icon and text
          Text(category, style: TextStyle(fontSize: 16)),
        ],
      );
    }).toList(),
  );
}

Widget _buildDonationMethod(String _donationMethod) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Constants.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      _donationMethod,
      style: TextStyle(
        color: Constants.primaryColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildDonationWeight(String _donationWeight) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Constants.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      _donationWeight,
      style: TextStyle(
        color: Constants.primaryColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildDonationDate(String date) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Constants.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      date,
      style: TextStyle(
        color: Constants.primaryColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildDonationTime(String time) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Constants.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      time,
      style: TextStyle(
        color: Constants.primaryColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildDonationAddress(String address) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Constants.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      address,
      style: TextStyle(
        color: Constants.primaryColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildDonationContactNumber(String contactNumber) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Constants.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      contactNumber,
      style: TextStyle(
        color: Constants.primaryColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildDonationStatus(String status) {
  Color statusColor;

  switch (status) {
    case 'Cancelled':
      statusColor = Colors.red;
      break;
    case 'Pending':
      statusColor = Colors.orange;
      break;
    case 'Confirmed':
      statusColor = Colors.blue;
      break;
    case 'Scheduled for Pick-up':
      statusColor = Colors.purple;
      break;
    case 'Completed':
      statusColor = Constants.primaryColor;
      break;
    default:
      statusColor = Constants.primaryColor;
  }

  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: statusColor,
        fontSize: 16,
      ),
    ),
  );
}

Widget _buildQRCodeGenerator(BuildContext context, _qrCodeData) {
  return Column(children: [
    Text("Present this QR Code to the organization for donation."),
    ListTile(
      title: _qrCodeData.isEmpty
          ? Text('No QR Code generated')
          : Column(
              children: [
                QrImageView(
                  data: _qrCodeData,
                  version: QrVersions.auto,
                  size: 300.0,
                ),
              ],
            ),
    ),
  ]);
}