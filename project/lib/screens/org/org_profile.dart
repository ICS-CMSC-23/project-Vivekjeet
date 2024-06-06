import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/user_provider.dart';
import 'package:provider/provider.dart';

class OrgProfilePage extends StatefulWidget {
  const OrgProfilePage({Key? key}) : super(key: key);

  @override
  _OrgProfilePageState createState() => _OrgProfilePageState();
}

class _OrgProfilePageState extends State<OrgProfilePage> {
  late User? _org;

  @override
  void initState() {
    super.initState();
    _org = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_org!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orgData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            return OrgProfileBody(orgData: orgData);
          }
        },
      ),
    );
  }
}

class OrgProfileBody extends StatefulWidget {
  final Map<String, dynamic> orgData;

  const OrgProfileBody({Key? key, required this.orgData}) : super(key: key);

  @override
  _OrgProfileBodyState createState() => _OrgProfileBodyState();
}

class _OrgProfileBodyState extends State<OrgProfileBody> {
  late Map<String, dynamic> _orgData;

  @override
  void initState() {
    super.initState();
    _orgData = widget.orgData;
  }

  final _org = FirebaseAuth.instance.currentUser;
  
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
            const SizedBox(
              height: 20,
            ),
            // Detail header
            header(),
            // Profile picture
            profilePicture(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_orgData['organizationName']}',
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              '${_org?.email}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${_orgData['contactNumber']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    // Navigate to the edit profile page and wait for result
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(orgData: _orgData, uid: _org!.uid),
                                      ),
                                    );

                                    // Update the UI with the returned data
                                    if (updated == true) {
                                      setState(() {
                                        // Trigger rebuild to reflect new data
                                      });
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    side: const BorderSide(color: Color(0xFF618264)),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF618264)), // Border color
                                    borderRadius: BorderRadius.circular(30), // Border radius
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _orgData['isOpen'] = !_orgData['isOpen']; // Toggle isOpen value
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(_org!.uid)
                                            .update({'isOpen': _orgData['isOpen']}); // Update isOpen in Firestore
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _orgData['isOpen'] == true
                                              ? const Text("Open for donations.")
                                              : const Text("Closed for donations."),
                                          Switch(
                                            value: _orgData['isOpen'] == true,
                                            onChanged: (bool value) {
                                              setState(() {
                                                _orgData['isOpen'] = value;
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(_org!.uid)
                                                    .update({'isOpen': value});
                                              });
                                            },
                                            activeColor: const Color.fromARGB(255, 186, 255, 201),
                                            // Change the color of the switch when it is on
                                            inactiveThumbColor: const Color.fromARGB(255, 255, 179, 186),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('About'),
                  Text(
                    '${_orgData['description']}' ?? 'No description yet.',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                child: _orgData['profilePicture'] != null
                  ? Image.network(
                      _orgData['profilePicture'],
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
        children: [
          const Spacer(),
          Text(
            '${_orgData['userName']}',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> orgData;
  final String uid;

  const EditProfilePage({Key? key, required this.orgData, required this.uid}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _userNameController;
  late TextEditingController _organizationNameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _descriptionController;

  File? _profileImage;

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

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

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.orgData['userName']);
    _organizationNameController = TextEditingController(text: widget.orgData['organizationName']);
    _contactNumberController = TextEditingController(text: widget.orgData['contactNumber']);
    _descriptionController = TextEditingController(text: widget.orgData['description']);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _organizationNameController.dispose();
    _contactNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            widget.orgData['profilePicture'] == null || _profileImage != null
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
                widget.orgData['profilePicture'],
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
                  onPressed: () {
                    _pickImageFromCamera();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () {
                    _pickImageFromGallery();
                  },
                ),
                if(_profileImage != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeImage();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
              cursorColor: const Color(0xFF618264)
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _organizationNameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
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
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _contactNumberController,
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Color(0xFF618264)), // Label color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF618264)), // Border color when not focused
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF618264), width: 2.0), // Border color when focused
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
              maxLines: null,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'userName': _userNameController.text.trim(),
                  'organizationName': _organizationNameController.text.trim(),
                  'contactNumber': _contactNumberController.text.trim(),
                  'description': _descriptionController.text.trim(),
                  'profilePicture': _profileImage ?? widget.orgData['profilePicture'], 
                };

                context
                  .read<UsersProvider>()
                  .editOrg(widget.uid, updatedData['userName'], updatedData['organizationName'], updatedData['contactNumber'], updatedData['description']);
                
                if(_profileImage != null){
                  context
                    .read<UsersProvider>()
                    .uploadProfilePicture(widget.uid, _profileImage!);  
                }
                Navigator.pop(context, true);
              },
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


