import 'package:flutter/material.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/screens/landingpage.dart';
import 'package:project/screens/signup.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './providers/auth_provider.dart';
import './screens/login.dart';
import 'providers/drive_provider.dart';
import 'screens/donor/donor_homepage.dart';
import 'screens/org/org_homepage.dart';
import './screens/admin_homepage.dart';
import 'screens/donor/donor_donate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => MyAuthProvider())),
        ChangeNotifierProvider(create: ((context) => UsersProvider())),
        ChangeNotifierProvider(create: ((context) => DonationsProvider())),
        ChangeNotifierProvider(create: ((context) => DriveProvider()))
      ],
      child: MyApp(),
    ),
  );
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
        '/': (context) => LandingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/donorhomepage': (context) => const DonorHomepage(),
        '/orghomepage': (context) => const OrgHomepage(),
        '/adminhomepage': (context) => const AdminHomepage(),
        '/donor_donate': (context) => const DonorDonate(),
      },
    );
  }
}