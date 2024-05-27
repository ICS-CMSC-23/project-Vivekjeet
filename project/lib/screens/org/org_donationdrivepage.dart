import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/models/drive_model.dart';
import 'package:provider/provider.dart';
import '../../providers/drive_provider.dart';

class DonationDrivesPage extends StatefulWidget {
  const DonationDrivesPage({super.key});

  @override
  _DonationDrivesPageState createState() => _DonationDrivesPageState();
}

class _DonationDrivesPageState extends State<DonationDrivesPage> {
  @override
  //creating for donors homepage
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> drivesStream = context.watch<DriveProvider>().drives;
    return StreamBuilder<QuerySnapshot>(
    stream: drivesStream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Error encountered! ${snapshot.error}"),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
          // ignore: avoid_print
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        // Check if snapshot has no data or if docs is empty
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('No available drives.',
                style: TextStyle(fontSize: 20, color: Colors.pink)),
            // Text (snapshot.data!.docs.toString()),
          ],
        );
      } else {
        // If snapshot has data and docs is not empty
        return ListView.builder(
          itemCount: snapshot.data?.docs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: ((context, index) {
            DriveModel drive = DriveModel.fromJson(snapshot.data?.docs[index].data() as Map<String, dynamic>);
            return Container(
              child: Text(drive.name)
               
            );
          
            
          }),
        );
      }
    },
  );
  }
}
