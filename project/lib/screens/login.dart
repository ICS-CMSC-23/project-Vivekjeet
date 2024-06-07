import 'package:email_validator/email_validator.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'signup.dart';


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
        prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF618264)),
        hintText: "Email",
        hintStyle: const TextStyle(color: Color(0xFF618264)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF618264)), 
            borderRadius: BorderRadius.circular(50),
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)), 
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      style: const TextStyle(color: Colors.black),
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
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF618264)),
        hintText: "Password",
        hintStyle: const TextStyle(color: Color.fromARGB(175, 42, 46, 52)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF618264)), 
            borderRadius: BorderRadius.circular(50),
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)), 
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      style: const TextStyle(color: Colors.black),
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
              if (context.mounted) Navigator.pop(context);
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
              const Color(0xFF618264),
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

    final googleLogin = Padding(
      key: const Key('loginButton'),
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: SizedBox(
        width: 200.0, // Adjust width as needed
        height: 50.0, // Adjust height as needed
        child: OutlinedButton(
          onPressed: () async {
            // Handle Google login
          },
          style: ButtonStyle(
            side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: Color(0xFF618264))),
            shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'images/google.png', // Replace with the path to your Google logo image
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 40,),
              const Text(
                "Sign in with Google",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );


    //Sign up button for new users
    final signUpButton = Padding(
      key: const Key('signUpButton'),
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF618264))),
          TextButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SignupPage(),
                ),
              );
            },
            child: const Text("Signup here", style: TextStyle(color: Color(0xFF618264), fontWeight: FontWeight.bold),),
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
            Image.asset('images/login_logo.png'),
            const SizedBox(height: 10),
            const Text(
              " Welcome back!",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 32, color: Colors.black),
            ),
            const SizedBox(height: 20),
            email,
            const SizedBox(height: 10),
            password,
            loginButton,
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(), 
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Or continue with"),
                ),
                Expanded(
                  child: Divider(), 
                ),
              ],
            ),
            const SizedBox(height: 10),
            googleLogin,
            signUpButton,
            const SizedBox(height: 15),
          ],
        ),
        )
      ),
    );
  }
}