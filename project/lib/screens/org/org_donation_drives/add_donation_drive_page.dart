import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/drive_model.dart';
import 'package:project/providers/drive_provider.dart';
import 'package:provider/provider.dart';

class AddDonationDrivePage extends StatefulWidget {
  @override
  _AddDonationDrivePageState createState() => _AddDonationDrivePageState();
}

class _AddDonationDrivePageState extends State<AddDonationDrivePage> {
  final _formKey = GlobalKey<FormState>();
  final _driveNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<File> driveImages = [];
  Map<int, File> _driveProofs = {};
  int _nextDriveProofId = 0;

  Future<void> _pickImageFromGalleryForDrive(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        for (var pickedFile in pickedFiles) {
          _driveProofs[_nextDriveProofId++] = File(pickedFile.path);
          driveImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _pickImageFromCameraForDrive() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _driveProofs[_nextDriveProofId++] = File(pickedFile.path);
        driveImages.add(File(pickedFile.path));
      });
    }
  }

  void removeDriveImage(int id) {
    setState(() {
      _driveProofs.remove(id);
      driveImages.removeAt(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Donation Drive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _driveNameController,
                decoration: const InputDecoration(labelText: 'Drive Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a drive name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Upload images: "),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImageFromCameraForDrive,
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () {
                      _pickImageFromGalleryForDrive(ImageSource.gallery);
                    },
                  ),   
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _driveProofs.entries.map((entry) {
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
                          icon: const Icon(Icons.delete, color: Colors.red,),
                          onPressed: () {
                            setState(() {
                              removeDriveImage(id);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:() async {

                  if(_formKey.currentState!.validate() && driveImages.isNotEmpty){
                    DocumentReference orgRef = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');
                    DriveModel newDrive = DriveModel.fromJson({
                      'driveName': _driveNameController.text.trim(),
                      'description': _descriptionController.text.trim(),
                      'organization': orgRef,
                      'photos': [],
                      'donations': []
                    });
                    
                    await context.read<DriveProvider>().addDrive(newDrive, driveImages);
                    if(context.mounted) Navigator.pop(context);
                  }

                },
                child: const Text('Add Drive'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
