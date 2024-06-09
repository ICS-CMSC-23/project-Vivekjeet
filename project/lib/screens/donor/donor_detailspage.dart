

import 'package:flutter/material.dart';
import 'package:project/screens/constants.dart';
import 'package:project/models/user_model.dart';
import 'package:project/providers/drive_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorDetails extends StatefulWidget {
  const DonorDetails({super.key});
  @override
  _DonorDetailsState createState() => _DonorDetailsState();
}

class _DonorDetailsState extends State<DonorDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final UserModel? selectedOrganization = ModalRoute.of(context)!.settings.arguments as UserModel?;
      if (selectedOrganization != null && selectedOrganization.id != null) {
        Provider.of<DriveProvider>(context, listen: false)
            .loadDrivesOfOrganization(selectedOrganization.id!);
      } else {
        print("No valid organization selected or ID is missing");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserModel? selectedOrganization = ModalRoute.of(context)!.settings.arguments as UserModel?;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<DriveProvider>(context).drives,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return OrganizationDetailsBody(
              organization: selectedOrganization!,
              drives: snapshot.data?.docs ?? [],
            );
          }
        },
      ),
    );
  }
}

class OrganizationDetailsBody extends StatelessWidget {
  final UserModel organization;
  final List<QueryDocumentSnapshot> drives;

  const OrganizationDetailsBody({
    Key? key,
    required this.organization,
    required this.drives,
  }) : super(key: key);

  SizedBox organizationPicture(Size size) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB0D9B1),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  )
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: organization.profilePicture != null
                    ? Image.network(
                        organization.profilePicture!,
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.groups_rounded,
                        size: 250,
                        color: Colors.black54,
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            organization.organizationName ?? 'No organization name',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF618264),
                  Color(0xFFB0D9B1),
                  Color(0xFFB0D9B1),
                  Colors.white,
                ],
              ),
            ),
            child: ListView(
              children: [
                const SizedBox(height: 80), // Adjust this to give enough space for the back button
                header(),
                organizationPicture(size),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organization.organizationName ?? 'No organization name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        organization.description ?? 'No organization description.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        'Drives',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (drives.isNotEmpty)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: drives.map((driveDoc) {
                            var drive = driveDoc.data() as Map<String, dynamic>;
                            return SizedBox(
                              width: (size.width / 2) - 20,
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: drive['image'] != null
                                          ? Image.network(
                                              drive['image'],
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.volunteer_activism,
                                              size: 100,
                                              color: Constants.iconColor,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            drive['driveName'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Text(
                                            drive['description'],
                                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: organization.isOpen == true
                              ? () {
                                  Navigator.pushNamed(context, '/donor_donate', arguments: organization);
                                }
                              : null, // Disable the tap action if the organization is not open for donations
                          style: ElevatedButton.styleFrom(
                            backgroundColor: organization.isOpen == true ? Constants.primaryColor.withOpacity(0.8): Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            'D O N A T E',
                            style: TextStyle(
                              color: organization.isOpen == true ? Colors.white : Colors.black45,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 70,
            left: 20,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constants.primaryColor.withOpacity(.15),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                color: Constants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

