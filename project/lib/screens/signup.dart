import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _signUpKey = GlobalKey<FormState>();
  bool isDonor = true;

  List<TextEditingController> addressControllers = [TextEditingController()];
  void addAddressField() {
    setState(() {
      addressControllers.add(TextEditingController());
    });
  }
  void removeAddressField(int index) {
    if(index > 0) {
      setState(() {
        addressControllers.removeAt(index);
      });
    }
  }

  List<File> images = [];
  Map<int, File> _proofs = {};
  int _nextProofId = 0;
  List<String> base64String = [];
  Future<void> _pickImageFromGallery(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        for (var pickedFile in pickedFiles) {
          _proofs[_nextProofId++] = File(pickedFile.path);
          images.add(File(pickedFile.path));
        }
      });
    }
    for (var pickedFile in pickedFiles) {
      List<int> imageBytes = File(pickedFile!.path).readAsBytesSync();
      base64String.add(base64Encode(imageBytes));
      print(base64String);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _proofs[_nextProofId++] = File(pickedFile.path);
        images.add(File(pickedFile.path));
      });
    }

    List<int> imageBytes = File(pickedFile!.path).readAsBytesSync();
    base64String.add(base64Encode(imageBytes));
    print(base64String);
  }

  void removeImage(int id) {
    setState(() {
      _proofs.remove(id);
      images.removeAt(id);
      base64String.removeAt(id); 
      print(base64String);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController contactController = TextEditingController();
    TextEditingController organizationNameController= TextEditingController();

    //Form field for email
    final email = TextFormField(
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
      //Check if valid format
      validator: (value) {
      if (EmailValidator.validate(value!)) { 
        return null;
      } else {
        return "Please enter a valid email";
      }
      },
    );

    //Form field for password
    final password = TextFormField(
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
      //Check if not null and if >= 6
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null; // Return null if the input is valid
      },
    );
    
    //Form field for first name
    final name = TextFormField(
      key: const Key('nameField'),
      controller: nameController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 42, 46, 52)),
        hintText: "Name",
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
      validator: (value) {
        if (value == null || value.isEmpty){
          return 'Enter your name';
        }
        return null;
      },
    );

    //Form field for username
    final username = TextFormField(
      key: const Key('usernameField'),
      controller: usernameController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 42, 46, 52)),
        hintText: "Username",
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
      validator: (value) {
        if (value == null || value.isEmpty){
          return 'Enter your username';
        }
        return null;
      },
    );

    //Form field for address
    final addresses = Column(
      children: List.generate(addressControllers.length, (index) {
        return Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: TextFormField(
                  controller: addressControllers[index],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.home, color: Color.fromARGB(255, 42, 46, 52)),
                    hintText: "Address",
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
                  validator: (value) {
                    if (value == null || value.isEmpty){
                      return 'Enter your address';
                    }
                    return null;
                  },
                ),
              ),
            ),
            if(index > 0) 
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  removeAddressField(index);
                },
              ),
          ],
        );
      }),
    );

    final addAddressButton = ElevatedButton(
      onPressed: addAddressField,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color.fromARGB(255, 42, 46, 52),
        ),
      ),
      child: const Text('Add Address', style: TextStyle(color: Colors.white)),
    );


    //Form field for contact number
    final contact = TextFormField(
      controller: contactController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone, color: Color.fromARGB(255, 42, 46, 52)),
        hintText: "Contact Number",
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
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      //Check if valid format
      validator: (value) {
        if (value == null || value.isEmpty){
          return 'Enter your contact number';
        }

        return null;
      },
    );

    //Radio button to choose if donor or organization
    final userType = Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Radio(
            value: true,
            groupValue: isDonor,
            onChanged: (value) {
              setState(() {
                isDonor = value!;
              });
            },
            activeColor: const Color.fromARGB(255, 42, 46, 52),
          ),
          const Text('Donor'),
          Radio(
            value: false,
            groupValue: isDonor,
            onChanged: (value) {
              setState(() {
                isDonor = value!;
              });
            },
            activeColor: const Color.fromARGB(255, 42, 46, 52)
          ),
          const Text('Organization'),
        ],
      ),
    );

    //Form field for organization name
    final organizationName = TextFormField(
      controller: organizationNameController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.business, color: Color.fromARGB(255, 42, 46, 52)),
        hintText: "Organization Name",
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
      validator: (value) {
        if (isDonor == false && (value == null || value.isEmpty)){
          return 'Enter your organization name';
        }
        return null;
      },
    );

    // "Upload Proofs" section
    final uploadProofs = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Upload proofs: "),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                _pickImageFromCamera();
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () {
                _pickImageFromGallery(ImageSource.gallery);
              },
            ),   
          ],
        ),
        Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _proofs.entries.map((entry) {
          final id = entry.key;
          final file = entry.value;
          return Stack(
            children: [
              Image.file(
                file,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red,),
                  onPressed: () {
                    setState(() {
                      removeImage(id);
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
      )
      ]
    );

    //Button to register the new account
    final signupButton = Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: 
      Container(
        width: 100.0, 
        height: 50.0, 
        decoration: BoxDecoration( 
          borderRadius: BorderRadius.circular(0), 
        ),
        child: ElevatedButton(
          onPressed: () async {
            //Check first if validated
            if(_signUpKey.currentState!.validate()){
              _signUpKey.currentState!.save();

              UserModel details = UserModel.fromJson({
                'name': nameController.text.trim(),
                'userName': usernameController.text.trim(),
                'addresses': addressControllers.map((controller) => controller.text.trim()).toList(),
                'contactNumber': contactController.text.trim(),
                'type': isDonor ? 'Donor' : 'Organization',
                'isApproved': false,
                'organizationName': organizationNameController.text.isEmpty == true ? null : organizationNameController.text.trim(),
                'description': null,
                'proofs': null
              });

              await context.read<MyAuthProvider>().signUp(
                details,
                emailController.text.trim(),
                passwordController.text.trim(),
                images
              );

              if (context.mounted) Navigator.pop(context);
            }else{ //If not validated, a snackbar will pop up telling the user to fill up the form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fill up the signup sheet!')
                )
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(
              const Color.fromARGB(255, 42, 46, 52),
            ),
          ),
          child: const Text('S I G N U P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      )
    );

    //Goes back to login page
    final backButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Already have an account? ", style: TextStyle(color: Color.fromARGB(255, 42, 46, 52))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Text("Login here", style: TextStyle(color: Color.fromARGB(255, 42, 46, 52), fontWeight: FontWeight.bold),),
          )
        ],
      )
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Form(
          key: _signUpKey,
          child:ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: <Widget>[
            const Icon(Icons.logo_dev, size: 50, color: Color.fromARGB(255, 42, 46, 52),),
            const Text(
              "LET'S GET STARTED",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 42, 46, 52)),
            ),
            const Text(
              "Create an account to donate!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 42, 46, 52)),
            ),
            const SizedBox(height: 20),
            name,
            const SizedBox(height: 5,),
            username,
            const SizedBox(height: 5,),
            email,
            const SizedBox(height: 5,),
            addresses,
            addAddressButton,
            const SizedBox(height: 5,),
            contact,
            const SizedBox(height: 5,),
            password,
            userType,
            if(!isDonor) ...[
              organizationName,
              const SizedBox(height: 5),
              uploadProofs,
            ],
            signupButton,
            backButton
          ],
        ),)
      ),
    );
  }
}

