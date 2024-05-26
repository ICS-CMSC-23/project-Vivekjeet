import 'package:flutter/material.dart';

class DonationDrivesPage extends StatefulWidget {
  const DonationDrivesPage({super.key});

  @override
  _DonationDrivesPageState createState() => _DonationDrivesPageState();
}

class _DonationDrivesPageState extends State<DonationDrivesPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Donation Drives Page Solo',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
