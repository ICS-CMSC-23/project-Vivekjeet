import 'package:flutter/material.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/models/user_model.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> organizationsStream =
        context.watch<UsersProvider>().organizations;
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: const Icon(
            Icons.account_circle_rounded,
            size: 52,
          ),
        ),
        toolbarHeight: 75,
        iconTheme: IconThemeData(
          color: Colors.grey.shade800,
          size: 28,
        ),
        title: const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Administrator",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color(0xFF00371D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Welcome back!",
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              height: ((MediaQuery.of(context).size.width - 40) * (770 / 1440)),
              // color: Colors.green,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SvgPicture.asset(
                        'images/bg.svg',
                        width: MediaQuery.of(context).size.width - 40,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: -25,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'images/logo.png',
                        width: (MediaQuery.of(context).size.width - 40) * 0.45,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 25,
                    left: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'images/logo_caption.png',
                        width: (MediaQuery.of(context).size.width - 40) * 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 85,
                    left: 105,
                    child: Container(
                      height: 80,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF3B8B1E), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFB1D7B5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          context.read<UsersProvider>().fetchDonors();
                          Navigator.of(context).pushNamed('/admin-donorslist');
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.account_circle_rounded,
                              size: 28,
                              color: Color(0xFF3B8B1E),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              width: 200,
                              child: const Text(
                                'Donors',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4A8670),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 85,
                    left: 230,
                    child: Container(
                      height: 80,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF3B8B1E), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFB1D7B5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          context.read<UsersProvider>().fetchOrganizations();
                          Navigator.of(context).pushNamed('/admin-approvals');
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.add_task,
                              size: 28,
                              color: Color(0xFF3B8B1E),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              width: 200,
                              child: const Text(
                                'Approvals',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4A8670),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // alignment: Alignment.centerLeft,
              margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: const Text(
                "Organizations",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color(0xFF00371D),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              child: const Divider(
                thickness: 1,
                color: Color(0xFF00371D),
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
                      height: MediaQuery.of(context).size.height * 0.45,
                      // color: Colors.blue,
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  childAspectRatio: 10 / 15),
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            UserModel currentOrganization = UserModel.fromJson(
                                snapshot.data?.docs[index].data()
                                    as Map<String, dynamic>);
                            return GridTile(
                              child: GestureDetector(
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB1D7B5),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 150,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: currentOrganization
                                                          .profilePicture ==
                                                      null ||
                                                  currentOrganization
                                                          .profilePicture ==
                                                      ""
                                              ? const Center(
                                                  child: Text(
                                                      'No profile picture'))
                                              : Image.network(
                                                  currentOrganization
                                                      .profilePicture!,
                                                  fit: BoxFit.fitHeight,
                                                  loadingBuilder: (context,
                                                      child, progress) {
                                                    return progress == null
                                                        ? child
                                                        : const Center(
                                                            child: CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Color(
                                                                            0xFF00371D))));
                                                  },
                                                ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 15, 5, 0),
                                        alignment: Alignment.centerLeft,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            '${currentOrganization.organizationName}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Color(0xFF00371D),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 5),
                                        alignment: Alignment.centerLeft,
                                        child: currentOrganization.isOpen ==
                                                true
                                            ? const Text(
                                                'Open',
                                                style: TextStyle(
                                                  color: Color(0xFF00371D),
                                                  fontSize: 12,
                                                ),
                                              )
                                            : Text(
                                                'Closed',
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                  fontSize: 12,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
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
                                                    'About the organization',
                                                    style: TextStyle(
                                                      color: Color(0xFF00371D),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  side: const BorderSide(
                                                      color: Color(0xFF00371D),
                                                      width: 2),
                                                ),
                                                insetPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        30, 20, 30, 20),
                                                backgroundColor: Colors.white,
                                                content: SizedBox(
                                                    height: 300,
                                                    width: 300,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                        '${currentOrganization.description}',
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF00371D),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    )),
                                                actions: [
                                                  SizedBox(
                                                    height: 45,
                                                    width: 165,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF00371D),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                      ),
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                DonationsProvider>()
                                                            .fetchDonationsOfOrganization(
                                                                snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id);
                                                        Navigator.pop(
                                                            dialogContext);
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                '/admin-org-donationslist');
                                                      },
                                                      child: const Text(
                                                        'Show Donations',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontStyle: FontStyle
                                                                .normal),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: const Text('Close',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF00371D),
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
                            );
                          }),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
