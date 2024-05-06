import 'package:flutter/material.dart';
import './screens/login.dart';
import './screens/donor_homepage.dart';
import './screens/org_homepage.dart';
import './screens/admin_homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/donorhomepage': (context) => const DonorHomepage(),
        '/orghomepage': (context) => const OrgHomepage(),
        '/adminhomepage': (context) => const AdminHomepage(),
        
      },
    );
  }
}