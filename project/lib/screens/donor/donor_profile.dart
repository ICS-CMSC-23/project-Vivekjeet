import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class DonorProfile extends StatefulWidget {
  const DonorProfile({Key? key}) : super(key: key);

  @override
  _DonorProfileState createState() => _DonorProfileState();
}

class _DonorProfileState extends State<DonorProfile> {
  late User? _donor;

  @override
  void initState() {
    super.initState();
    _donor = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_donor!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final donorData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            return DonorProfileBody(donorData: donorData);
          }
        },
      ),
    );
  }
}

final _donor = FirebaseAuth.instance.currentUser;

class DonorProfileBody extends StatefulWidget {
  final Map<String, dynamic> donorData;

  const DonorProfileBody({Key? key, required this.donorData}) : super(key: key);

  @override
  _DonorProfileBodyState createState() => _DonorProfileBodyState();
}

class _DonorProfileBodyState extends State<DonorProfileBody> {
  late Map<String, dynamic> _donorData;

  @override
  void initState() {
    super.initState();
    _donorData = widget.donorData;
  }

  SizedBox profilePicture() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB0D9B1),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  )
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: _donorData['profilePicture'] != null
                  ? Image.network(
                      _donorData['profilePicture'],
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'images/temppfp.jpg', 
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            '${_donorData['name']}',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF618264),
              Color(0xFFB0D9B1),
              Color(0xFFB0D9B1),
              Colors.white
            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            header(), // Ensure this creates a similar layout
            profilePicture(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_donorData['name']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    '${_donor?.email}',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    '${_donorData['contactNumber']}',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Addresses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_donorData['addresses'] != null)
                    ..._donorData['addresses'].map<Widget>((address) {
                      return Text(
                        address,
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      );
                    }).toList(),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity, // Makes the container fill the available width
                    child: ElevatedButton(
                      onPressed: () async {
                        bool updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDonorProfile(donorData: _donorData),
                          ),
                        );
                        if (updated) {
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF618264),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDonorProfile extends StatefulWidget {
  final Map<String, dynamic> donorData;

  const EditDonorProfile({Key? key, required this.donorData}) : super(key: key);

  @override
  _EditDonorProfileState createState() => _EditDonorProfileState();
}

class _EditDonorProfileState extends State<EditDonorProfile> {
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _contactNumberController;
  List<TextEditingController> _addressControllers = [];
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.donorData['name']);
    _userNameController = TextEditingController(text: widget.donorData['userName']);
    _contactNumberController = TextEditingController(text: widget.donorData['contactNumber']);
    _addressControllers = widget.donorData['addresses']?.map<TextEditingController>(
      (address) => TextEditingController(text: address)).toList() ?? [];
    if (_addressControllers.isEmpty) _addAddress();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _profileImage = null;
    });
  }

  void _addAddress() {
    setState(() {
      _addressControllers.add(TextEditingController());
    });
  }

  void _removeAddress(int index) {
    if (_addressControllers.length > 1) {
      setState(() {
        _addressControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveProfile() async {
    var updatedData = {
      'name': _nameController.text.trim(),
      'userName': _userNameController.text.trim(),
      'contactNumber': _contactNumberController.text.trim(),
      'addresses': _addressControllers.map((controller) => controller.text.trim()).toList(),
    };

    if (_profileImage != null) {
      Provider.of<UsersProvider>(context, listen: false)
          .uploadProfilePicture(_donor!.uid, _profileImage!);
    }

    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
      .update(updatedData).then((_) => Navigator.pop(context, true));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Profile'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Profile Picture',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          widget.donorData['profilePicture'] == null || _profileImage != null
              ? _profileImage != null
                  ? Image.file(
                      _profileImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'images/temppfp.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
              : Image.network(
                  widget.donorData['profilePicture'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _pickImageFromCamera,
              ),
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: _pickImageFromGallery,
              ),
              if (_profileImage != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _removeImage,
                ),
            ],
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Color(0xFF618264)), // Label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF618264)), // Border color when not focused
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF618264), width: 2.0), // Border color when focused
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            style: const TextStyle(fontSize: 16.0),
            cursorColor: const Color(0xFF618264),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _userNameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Color(0xFF618264)), // Label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF618264)), // Border color when not focused
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF618264), width: 2.0), // Border color when focused
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            style: const TextStyle(fontSize: 16.0),
            cursorColor: const Color(0xFF618264),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _contactNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Contact Number',
              labelStyle: TextStyle(color: Color(0xFF618264)), // Label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF618264)), // Border color when not focused
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF618264), width: 2.0), // Border color when focused
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20),
          const Text(
            'Addresses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: _addressControllers
                .asMap()
                .entries
                .map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(color: Color(0xFF618264)), // Label color
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF618264)), // Border color when not focused
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF618264), width: 2.0), // Border color when focused
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                            ),
                            style: const TextStyle(fontSize: 16.0),
                            cursorColor: const Color(0xFF618264),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeAddress(index);
                          },
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
          TextButton(
            onPressed: _addAddress,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF618264),
            ),
            child: const Text('Add Address'),
          ),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF618264),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}