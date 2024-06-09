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
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';


class DonorDonations extends StatefulWidget {
  const DonorDonations({super.key});
  @override
  _DonorDonationsState createState() => _DonorDonationsState();
}

class _DonorDonationsState extends State<DonorDonations> {
  final List<String> _statuses = [
    "All",
    "Completed",
    "Pending",
    "Scheduled for Pick-up",
    "Confirmed",
    "Cancelled"
  ];
  List<bool> _selectedStatus = [true, false, false, false, false, false];
  String _currentStatus = "All";

  @override
  void initState() {
    super.initState();
    final donorId = FirebaseAuth.instance.currentUser?.uid;
    if (donorId != null) {
      Provider.of<DonationsProvider>(context, listen: false)
          .fetchDonationsByDonor(donorId);
    }
  }

  void _updateSelectedStatus(String selectedStatus) {
    setState(() {
      _currentStatus = selectedStatus ?? "All";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Filter",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Constants.primaryColor),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentStatus,
                          icon: Icon(Icons.arrow_downward, color: Colors.white),
                          iconSize: 18,
                          elevation: 10,
                          dropdownColor: Constants.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          style: TextStyle(color: Colors.white),
                          onChanged: (String? newValue) {
                            _updateSelectedStatus(newValue!);
                          },
                          items: _statuses
                              .map<DropdownMenuItem<String>>((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            Expanded(
              child: listDonations(context, _currentStatus),
            ),
          ],
        ),
      ),
    );
  }
}

Widget listDonations(BuildContext context, String status) {
  Stream<QuerySnapshot> donationsStream =
      context.watch<DonationsProvider>().donorDonations;

  final Map<String, Icon> _categoryIcons = {
    'Food': Icon(Icons.fastfood, color: Constants.iconColor),
    'Clothes': Icon(Icons.checkroom, color: Constants.iconColor),
    'Cash': Icon(Icons.attach_money, color: Constants.iconColor),
    'Necessities': Icon(Icons.shopping_cart, color: Constants.iconColor),
  };

  final Map<String, Color> _colors = {
    'Pending': Color(0xfff4a261).withOpacity(0.9),
    'Confirmed': Color(0xff1d3557).withOpacity(0.8),
    'Scheduled for Pick-up': Color(0xffe9c46a).withOpacity(1),
    'Completed': Constants.primaryColor.withOpacity(0.8),
    'Cancelled': Color(0xffe63946).withOpacity(0.8),

    // 'Pending': Color(0xfff4a261),
    // 'Confirmed': Color(0xff1d3557),
    // 'Scheduled for Pick-up': Color(0xffe9c46a),
    // 'Completed': Constants.primaryColor,
    // 'Cancelled': Color(0xffe63946),
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
        final filteredDonations = snapshot.data!.docs.where((doc) {
          if (status == "All") {
            return true;
          }
          return (doc.data() as Map<String, dynamic>)['status'] == status;
        }).toList();
        return ListView.builder(
          itemCount: filteredDonations.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: ((context, index) {
            Map<String, dynamic> donation =
                filteredDonations[index].data() as Map<String, dynamic>;
            bool _isCancelDisabled = false;

            if (donation['status'] == 'Confirmed' ||
                donation['status'] == 'Scheduled for Pick-up' ||
                donation['status'] == 'Completed' ||
                donation['status'] == 'Cancelled') _isCancelDisabled = true;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              key: Key(filteredDonations[index].id),
              child: ListTile(
                leading: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.black54,
                  size: 50,
                ),
                title: FutureBuilder<DocumentSnapshot>(
                  future: (donation['organization'] as DocumentReference).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading organization details...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ));
                    }
                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status:  '),
                        Container(
                          child: Text('${donation['status']}',
                              style: TextStyle(color: Colors.white)),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _colors[donation['status']],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: EdgeInsets.only(right: 5),
                        ),
                        // Text('${donation['status']}',
                        //       style: TextStyle(
                        //           color: _colors[donation['status']])),
                      ],
                    ),
                    // Text('Status: ${donation['status']}',
                    //     style: TextStyle(color: _colors[donation['status']])),
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
                // tileColor: _colors[donation['status']],
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
                                      future: (donation['organization']
                                              as DocumentReference)
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.exists) {
                                          Map<String, dynamic> data =
                                              snapshot.data!.data()
                                                  as Map<String, dynamic>;
                                          String organizationName =
                                              data['name'];
                                          return Text(organizationName,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ));
                                        } else {
                                          return Text(
                                              "Organization details unavailable",
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
                                            context, donation['donationId'], donation['status']),
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
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _colors[
                                                'Cancelled'], // Green red color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
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
                                          child: Text('Cancel Donate',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xff296e48), // Green color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Back',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
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
  Map<String, Color> colors = {
    'Pending': Color(0xfff4a261),
    'Confirmed': Color(0xff1d3557),
    'Scheduled for Pick-up': Color(0xffe9c46a),
    'Completed': Constants.primaryColor,
    'Cancelled': Color(0xffe63946),
  };

  Color? statusColor = colors[status];

  // switch (status) {
  //   case 'Cancelled':
  //     statusColor = Colors.red;
  //     break;
  //   case 'Pending':
  //     statusColor = Colors.orange;
  //     break;
  //   case 'Confirmed':
  //     statusColor = Colors.blue;
  //     break;
  //   case 'Scheduled for Pick-up':
  //     statusColor = Colors.purple;
  //     break;
  //   case 'Completed':
  //     statusColor = Constants.primaryColor;
  //     break;
  //   default:
  //     statusColor = Constants.primaryColor;
  // }

  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: statusColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  );

  
}


Widget _buildQRCodeGenerator(BuildContext context, _qrCodeData, status) {
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
                ElevatedButton(
                  onPressed: () {
                    // Function to download QR code
                    _downloadQRCode(context, _qrCodeData, status);
                    //pop
                    Navigator.pop(context);
                  },
                  child: Text('Download QR Code'),
                ),
              ],
            ),
    ),
  ]);
}



void _downloadQRCode(BuildContext context, String qrCodeData, String status) async {
  if (context == null) {
    print("Error: Null context provided");
    return;
  }

  try {
    // Create a white background
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, 300, 350), paint);

    // Generate QR code image
    final qrValidationResult = QrValidator.validate(
      data: qrCodeData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('QR Code generation failed');
    }
    final qrCode = qrValidationResult.qrCode;
    final qrPainter = QrPainter.withQr(
      qr: qrCode!,
      color: Colors.black,
      emptyColor: Colors.white,
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );

    final qrImageSize = 300.0;
    final offSet = (300 - qrImageSize) / 2;
    final qrImageRect = Rect.fromLTWH(offSet, offSet, qrImageSize, qrImageSize);
    qrPainter.paint(canvas, qrImageRect.size);

    // Overlay additional information
    final textStyle = ui.TextStyle(
      color: Colors.black,
      fontSize: 12.0,
    );
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: 12.0,
    ))
      ..pushStyle(textStyle)
      ..addText('Date Downloaded: ${DateTime.now().toString()} \nStatus: $status');
    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 300));
    canvas.drawParagraph(paragraph, const Offset(0, 310));

    // Convert canvas to image
    final generatedImage = await recorder.endRecording().toImage(300, 350);
    final byteDataWithText = await generatedImage.toByteData(format: ui.ImageByteFormat.png);
    final bytesWithText = byteDataWithText!.buffer.asUint8List();

    // Create a temporary file path
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String filePath = '$tempPath/qr_code_with_text.png';

    // Write the image bytes to a temporary file
    await File(filePath).writeAsBytes(bytesWithText);

    // Save the image to the photo gallery
    await GallerySaver.saveImage(filePath);

    // Show a toast or snackbar indicating successful download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR Code saved to gallery')),
    );
  } catch (e) {
    // Show error message if download fails
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save QR Code')),
    );
  }
}

