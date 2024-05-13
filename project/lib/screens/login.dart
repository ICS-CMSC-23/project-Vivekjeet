import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'signup.dart';
// import './donor_homepage.dart';
// import './org_homepage.dart';
// import './admin_homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    //Form field for the email
    final email = TextFormField(
      key: const Key('emailField'),
      controller: emailController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 42, 46, 52)),
        hintText: "Email",
        hintStyle: const TextStyle(color: Color.fromARGB(175, 42, 46, 52)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 42, 46, 52)), 
            borderRadius: BorderRadius.circular(50),
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 42, 46, 52)), 
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      style: const TextStyle(color: Color.fromARGB(255, 42, 46, 52)),
      //Checks if correct format
      validator: (value){
      if (EmailValidator.validate(value!)) { 
        return null;
        } else {
        return "Please enter a valid email";
        }
      },
    );

    //Form field for the password
    final password = TextFormField(
      key: const Key('pwField'),
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 42, 46, 52)),
        hintText: "Password",
        hintStyle: const TextStyle(color: Color.fromARGB(175, 42, 46, 52)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 42, 46, 52)), 
            borderRadius: BorderRadius.circular(50),
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 42, 46, 52)), 
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      style: const TextStyle(color: Color.fromARGB(255, 42, 46, 52)),
      //Check if not null and if length >= 6ds
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          print(value.length);
          return 'Password must be at least 6 characters';
        }
        return null; // Return null if the input is valid
      },
    );

    //Form field for login button
    final loginButton = Padding(
      key: const Key('loginButton'),
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 5),
      child: Container(
        width: 100.0, 
        height: 50.0, 
        decoration: BoxDecoration( 
          borderRadius: BorderRadius.circular(0), 
        ),
        child: ElevatedButton(
          onPressed: () async {
            if(_loginKey.currentState!.validate()){
              await context.read<MyAuthProvider>().signIn(
                emailController.text.trim(),
                passwordController.text.trim(),
              );
            }else{ //If not validated, a snackbar will pop up telling the user to fill up the form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login properly!')
                )
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(
              const Color.fromARGB(255, 42, 46, 52),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('L O G I N   ', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
              Icon(Icons.login, color: Color.fromARGB(255, 255, 255, 255),)
            ]
          )
        ),
      )
    );

    //Sign up button for new users
    final signUpButton = Padding(
      key: const Key('signUpButton'),
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Don't have an account? ", style: TextStyle(color: Color.fromARGB(255, 42, 46, 52))),
          TextButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SignupPage(),
                ),
              );
            },
            child: const Text("Signup here", style: TextStyle(color: Color.fromARGB(255, 42, 46, 52), fontWeight: FontWeight.bold),),
          )
        ],
      )
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Form(
          key: _loginKey,
          child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: <Widget>[
            const Icon(Icons.logo_dev, size: 50, color: Color.fromARGB(255, 42, 46, 52)),
            const SizedBox(height: 10),
            const Text(
              "T I T L E",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 42, 46, 52)),
            ),
            const SizedBox(height: 20),
            email,
            const SizedBox(height: 10),
            password,
            loginButton,
            signUpButton
          ],
        ),
        )
      ),
    );
  }
}