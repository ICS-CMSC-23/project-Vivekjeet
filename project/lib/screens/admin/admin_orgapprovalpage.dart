import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/models/user_model.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});
  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> organizationsStream =
        context.watch<UsersProvider>().organizations;

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
                "Organization Approvals",
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            const Text(
              "Approval Requests",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Color(0xFF00371D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 10),
              child: const Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Organization",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF00371D),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Status",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF00371D),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Action",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF00371D),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: organizationsStream,
                builder: (context, snapshot) {
                  List<dynamic> organizations = snapshot.data?.docs ?? [];
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
                  } else if (!snapshot.hasData || organizations.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Center(
                        child: Text(
                          "No organization data available",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF00371D),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          height: MediaQuery.of(context).size.height * 0.67,
                          // color: Colors.blue,
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 20,
                                childAspectRatio: 20 / 10,
                              ),
                              itemCount: (snapshot.data?.docs.length ?? 0) * 3,
                              itemBuilder: (context, index) {
                                UserModel currentOrganization =
                                    UserModel.fromJson(
                                        snapshot.data?.docs[index ~/ 3].data()
                                            as Map<String, dynamic>);
                                if (index % 3 == 0) {
                                  return Container(
                                    alignment: Alignment.center,
                                    // color: Colors.green,
                                    height: 20,
                                    child: SingleChildScrollView(
                                      child: Text(
                                        "${currentOrganization.organizationName}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Color(0xFF00371D),
                                            fontSize: 12),
                                      ),
                                    ),
                                  );
                                } else if (index % 3 == 1) {
                                  return Container(
                                    alignment: Alignment.center,
                                    // color: Colors.orange,
                                    height: 20,
                                    child: currentOrganization.isApproved ==
                                            true
                                        ? const Text(
                                            "Approved",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFF3B8B1E),
                                                fontSize: 14),
                                          )
                                        : currentOrganization.isApproved ==
                                                false
                                            ? Text(
                                                "Disapproved",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.red.shade800,
                                                    fontSize: 14),
                                              )
                                            : Text(
                                                "Pending",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.grey.shade800,
                                                    fontSize: 14),
                                              ),
                                  );
                                } else if (index % 3 == 2) {
                                  return Container(
                                    alignment: Alignment.center,
                                    // color: Colors.purple,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4FC226),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                      ),
                                      child: const Text(
                                        'Action',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontStyle: FontStyle.normal),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder:
                                                (dialogContext) => Material(
                                                      color: Colors.transparent,
                                                      shadowColor:
                                                          Colors.grey[700],
                                                      elevation: 0.5,
                                                      child: AlertDialog(
                                                          title: const Text(
                                                              'Proof of Legitimacy',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF00371D),
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            side: const BorderSide(
                                                                color: Color(
                                                                    0xFF00371D),
                                                                width: 2),
                                                          ),
                                                          insetPadding:
                                                              const EdgeInsets
                                                                  .fromLTRB(30,
                                                                  20, 30, 20),
                                                          backgroundColor:
                                                              Colors.white,
                                                          content: SizedBox(
                                                              height: 300,
                                                              width: 300,
                                                              child: currentOrganization
                                                                          .proofs ==
                                                                      null
                                                                  ? const Text(
                                                                      'No proof attached.',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF00371D),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  : ListView
                                                                      .builder(
                                                                          itemCount: currentOrganization
                                                                              .proofs!
                                                                              .length,
                                                                          itemBuilder:
                                                                              (BuildContext context, int i) {
                                                                            return Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  'Proof #${i + 1}',
                                                                                  textAlign: TextAlign.left,
                                                                                  style: const TextStyle(color: Color(0xFF00371D), fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 250,
                                                                                  child: Image.network(
                                                                                    currentOrganization.proofs![i],
                                                                                    fit: BoxFit.fitHeight,
                                                                                    loadingBuilder: (context, child, progress) {
                                                                                      return progress == null ? child : const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00371D))));
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                              ],
                                                                            );
                                                                          })),
                                                          actions: [
                                                            SizedBox(
                                                              height: 50,
                                                              width: 95,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFF3B8B1E),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                ),
                                                                onPressed: () {
                                                                  context
                                                                      .read<
                                                                          UsersProvider>()
                                                                      .editOrgStatus(
                                                                          snapshot
                                                                              .data
                                                                              ?.docs[index ~/ 3]
                                                                              .id,
                                                                          true);
                                                                  Navigator.pop(
                                                                      dialogContext);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          const SnackBar(
                                                                    content: Text(
                                                                        "Organization approved.",
                                                                        softWrap:
                                                                            true,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2),
                                                                    backgroundColor:
                                                                        Color(
                                                                            0xFF4FC226),
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                  ));
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Approve',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 50,
                                                              width: 80,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.red
                                                                          .shade800,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                ),
                                                                onPressed: () {
                                                                  context.read<UsersProvider>().editOrgStatus(
                                                                      snapshot
                                                                          .data
                                                                          ?.docs[index ~/
                                                                              3]
                                                                          .id,
                                                                      false);
                                                                  Navigator.pop(
                                                                      dialogContext);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                    content: const Text(
                                                                        "Organization disapproved.",
                                                                        softWrap:
                                                                            true,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            2),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red
                                                                            .shade800,
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                  ));
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Reject',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal),
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Close',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(0xFF00371D),
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                  );
                                } else {
                                  return Container();
                                }
                              })));
                })
          ],
        ),
      ),
    );
  }
}
