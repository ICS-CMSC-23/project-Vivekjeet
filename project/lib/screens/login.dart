import 'package:flutter/material.dart';
import './donor_homepage.dart';
import './org_homepage.dart';
import './admin_homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final loginAsDonorButton = Padding(
      key: const Key('loginAsDonorButton'),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DonorHomepage(),
            ),
          );
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
        ),
        child: const Text('Login as Donor', style: TextStyle(color: Colors.white)),
      ),
    );

    final loginAsOrgButton = Padding(
      key: const Key('loginAsOrgButton'),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OrgHomepage(),
            ),
          );
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
        ),
        child: const Text('Login as Organization', style: TextStyle(color: Colors.white)),
      ),
    );

    final loginAsAdminButton = Padding(
      key: const Key('loginAsAdminButton'),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminHomepage(),
            ),
          );
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
        ),
        child: const Text('Login as Admin', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: <Widget>[
            const Text(
              "Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            loginAsDonorButton,
            loginAsOrgButton,
            loginAsAdminButton
          ],
        ),
      ),
    );
  }
}