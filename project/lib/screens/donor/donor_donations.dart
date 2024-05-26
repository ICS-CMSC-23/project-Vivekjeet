//donation page

import 'package:flutter/material.dart';
import 'package:project/screens/constants.dart';
import 'package:project/models/user_model.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/models/donation_model.dart';
import 'package:flutter/material.dart';

class DonorDonations extends StatefulWidget {
  const DonorDonations({super.key});
  @override
  _DonorDonationsState createState() => _DonorDonationsState();
}

class _DonorDonationsState extends State<DonorDonations> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: <Widget>[
            const Text(
              "Donor Donations to all organizations",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            Form(
              key: _formKey,
              child: Column(
            
              ),
            ),
          ],
        ),
      ),
    );
  }
}