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

  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states){
      if(states.contains(MaterialState.selected)){
          return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _orgData.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Welcome, ${_orgData['organizationName']}!'),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Adjust the curvature as needed
                  color: Colors.grey[200], // Set the background color
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    _orgData['isOpen']
                          ? Text("Open for donations.")
                          : Text("Closed for donations."),
                    Switch(
                      thumbIcon: thumbIcon,
                        value: _orgData['isOpen'],
                        onChanged: (bool value){
                          setState(() {
                            _orgData['isOpen'] = value;
                          });
                        },
                        activeColor: const Color.fromARGB(255,186,255,201), // Change the color of the switch when it is on
                        inactiveThumbColor: const Color.fromARGB(255,255,179,186)
                    )
                  ],
                ),
              )
            ],
          )
        : const CircularProgressIndicator(), 
      ),
    );
  }
}
