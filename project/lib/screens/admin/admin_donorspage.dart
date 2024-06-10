import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/models/user_model.dart';

class AdminDonorsPage extends StatefulWidget {
  const AdminDonorsPage({super.key});
  @override
  State<AdminDonorsPage> createState() => _AdminDonorsPageState();
}

class _AdminDonorsPageState extends State<AdminDonorsPage> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> donorsStream = context.watch<UsersProvider>().donors;
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
                "Active Donors",
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
                  "Donors",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xFF00371D),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  height: MediaQuery.of(context).size.height * 0.45,
                  // color: Colors.blue,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: donorsStream,
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
                                "No donor data available",
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
                              UserModel currentDonor = UserModel.fromJson(
                                  snapshot.data?.docs[index].data()
                                      as Map<String, dynamic>);
                              return Container(
                                  child: ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                leading: const Icon(
                                  Icons.person,
                                  color: Color(0xFF00371D),
                                ),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      currentDonor.name,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color(0xFF00371D),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      currentDonor.contactNumber,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: GestureDetector(
                                  child: const Icon(
                                    Icons.share_location,
                                    color: Color(0xFF00371D),
                                    size: 32,
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (dialogContext) => Material(
                                              color: Colors.transparent,
                                              shadowColor: Colors.grey[700],
                                              elevation: 0.5,
                                              child: AlertDialog(
                                                  title: const Text(
                                                      'Donor Addresses',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF00371D),
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFF00371D),
                                                        width: 2),
                                                  ),
                                                  insetPadding:
                                                      const EdgeInsets.fromLTRB(
                                                          30, 20, 30, 20),
                                                  backgroundColor: Colors.white,
                                                  content: SizedBox(
                                                      height: 200,
                                                      width: 300,
                                                      child: ListView.builder(
                                                          itemCount:
                                                              currentDonor
                                                                  .addresses
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int i) {
                                                            return ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons
                                                                    .location_on_rounded,
                                                                color: Color(
                                                                    0xFF00371D),
                                                              ),
                                                              title: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <Widget>[
                                                                  Text(
                                                                    currentDonor
                                                                        .addresses[i],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: const TextStyle(
                                                                        color: Color(
                                                                            0xFF00371D),
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                    'Address ${i + 1}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          })),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text('Close',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF00371D),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            dialogContext);
                                                      },
                                                    )
                                                  ]),
                                            ));
                                  },
                                ),
                              ));
                            });
                      }))
            ],
          )),
    );
  }
}
