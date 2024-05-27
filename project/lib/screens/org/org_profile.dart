import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrgProfilePage extends StatefulWidget {
  const OrgProfilePage({Key? key}) : super(key: key);

  @override
  _OrgProfilePageState createState() => _OrgProfilePageState();
}

class _OrgProfilePageState extends State<OrgProfilePage> {
  late User? _org;
  late Map<String, dynamic> _orgData = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _org = FirebaseAuth.instance.currentUser;
    if (_org != null) {
      DocumentSnapshot orgDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_org!.uid)
          .get();
      setState(() {
        _orgData = orgDataSnapshot.data() as Map<String, dynamic>? ?? {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _orgData.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Welcome, ${_orgData['organizationName']}!'),
                ],
              )
            : const CircularProgressIndicator(), 
      ),
    );
  }
}
