import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/drive_model.dart';
import 'package:project/providers/drive_provider.dart';
import 'package:provider/provider.dart';

class EditDonationDrivePage extends StatefulWidget {
  final String driveId;
  final String initialDriveName;
  final String initialDescription;
  final List<String> initialPhotos;

  EditDonationDrivePage({
    required this.driveId,
    required this.initialDriveName,
    required this.initialDescription,
    required this.initialPhotos,
  });

  @override
  _EditDonationDrivePageState createState() => _EditDonationDrivePageState();
}

class _EditDonationDrivePageState extends State<EditDonationDrivePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _driveNameController;
  late TextEditingController _descriptionController;
  List<String> drivePhotos = [];
  List<String> removedPhotos = [];
  List<File> newDriveImages = [];
  Map<int, File> _driveProofs = {};
  int _nextDriveProofId = 0;

  @override
  void initState() {
    super.initState();
    _driveNameController = TextEditingController(text: widget.initialDriveName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    drivePhotos = List.from(widget.initialPhotos);
  }

  Future<void> _pickImageFromGalleryForDrive() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        for (var pickedFile in pickedFiles) {
          _driveProofs[_nextDriveProofId++] = File(pickedFile.path);
          newDriveImages.add(File(pickedFile.path));
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
        newDriveImages.add(File(pickedFile.path));
      });
    }
  }

  void removeDriveImage(int id) {
    setState(() {
      _driveProofs.remove(id);
      newDriveImages.removeAt(id);
    });
  }

  void removeExistingPhoto(String url) {
    setState(() {
      drivePhotos.remove(url);
      removedPhotos.add(url);
    });
  }

  Future<void> _editDonationDrive() async {
    if (_formKey.currentState!.validate() && (drivePhotos.isNotEmpty || newDriveImages.isNotEmpty)) {
      DocumentReference orgRef = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');
      DriveModel updatedDrive = DriveModel.fromJson({
        'driveId': widget.driveId,
        'driveName': _driveNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'organization': orgRef,
        'photos': drivePhotos,
        'donations': []
      });

      await _showConfirmationDialog(context, updatedDrive, newDriveImages);
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, DriveModel updatedDrive, List<File> newDriveImages) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please review the details before updating:'),
                const SizedBox(height: 10),
                Text('Drive Name: ${updatedDrive.driveName}'),
                Text('Description: ${updatedDrive.description}'),
                Text('Existing Photos: '),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: drivePhotos.map((url) {
                    return Image.network(url, width: 100, height: 100, fit: BoxFit.cover);
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text('New Photos: '),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: newDriveImages.map((image) {
                    return Image.file(image, width: 100, height: 100, fit: BoxFit.cover);
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel',
                style: TextStyle(
                  color: Color.fromARGB(255, 168, 43, 34),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<DriveProvider>().updateDrive(widget.driveId, updatedDrive, newDriveImages, removedPhotos);
                if(context.mounted) Navigator.pop(context);
                if(context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF618264),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              )
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donation Drive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _driveNameController,
                decoration: const InputDecoration(
                labelText: 'Drive Name',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a drive name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10,),
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
                    onPressed: _pickImageFromGalleryForDrive,
                  ),   
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: drivePhotos.map((url) {
                  return Stack(
                    children: [
                      Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              removeExistingPhoto(url);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList() +
                _driveProofs.entries.map((entry) {
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
                          icon: const Icon(Icons.delete, color: Colors.red),
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
                onPressed: _editDonationDrive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF618264),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
