// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/models/donation_model.dart';
import 'package:project/models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';


class Constants {
  // Primary color
  static var primaryColor = const Color(0xff296e48);
  static var blackColor = Colors.black54;
  static var iconColor = primaryColor.withOpacity(0.6);
}

class DonorDonate extends StatefulWidget {
  const DonorDonate({Key? key}) : super(key: key);

  @override
  _DonorDonateState createState() => _DonorDonateState();
}

class _DonorDonateState extends State<DonorDonate> {
  final _formKey = GlobalKey<FormState>();

  final DocumentReference _currentDonorId = FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');

  final Map<String, Icon> _categoryIcons = {
    'Food': Icon(Icons.fastfood, color: Constants.iconColor),
    'Clothes': Icon(Icons.checkroom, color: Constants.iconColor),
    'Cash': Icon(Icons.attach_money, color: Constants.iconColor),
    'Necessities': Icon(Icons.shopping_cart, color: Constants.iconColor),
  };

  final Map<String, bool> _categorySelections = {
    'Food': false,
    'Clothes': false,
    'Cash': false,
    'Necessities': false,
  };

  List<String> _additionalItems = [];
  String _donationMethod = 'Pick up';
  bool _isPickup = true;
  String _weightUnit = 'lb';
  File? _photo;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TextEditingController _contactController = TextEditingController();

  List<TextEditingController> _addressControllers = [];

  String _qrCodeData = "";
  String? donationId;
  bool showQr = false;
  List<String> temp = [];
  List<String> _addressOptions = [];
  String? _selectedAddress;



  @override
  void initState() {
    super.initState();
    _fetchDonorAddresses();
  }

  // void _fetchDonorAddresses() async {
  //   User? donor = FirebaseAuth.instance.currentUser;
  //   if (donor != null) {
  //     DocumentSnapshot donorData = await FirebaseFirestore.instance.collection('users').doc(donor.uid).get();
  //     List<dynamic> addresses = donorData['addresses'] ?? [];
  //     setState(() {
  //       _addressControllers = addresses.map((address) => TextEditingController(text: address)).toList();
  //       if (_addressControllers.isEmpty) {
  //         _addressControllers.add(TextEditingController());
  //       }
  //     });
  //   }
  // }
  void _fetchDonorAddresses() async {
    User? donor = FirebaseAuth.instance.currentUser;
    if (donor != null) {
      DocumentSnapshot donorData = await FirebaseFirestore.instance.collection('users').doc(donor.uid).get();
      List<dynamic> addresses = donorData['addresses'] ?? [];
      setState(() {
        _addressOptions = List<String>.from(addresses);
        if (_addressOptions.isNotEmpty) {
          _selectedAddress = _addressOptions.first;
        }
      });
    }
  }



  void _removeAddressField(int index) {
    if (_addressControllers.length > 1) {
      setState(() {
        _addressControllers.removeAt(index);
      });
    } else {
      _addressControllers[index].clear();
    }
  }

  final TextEditingController _textController = TextEditingController();

  Future<void> _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _photo = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.iconColor,
        title: const Text('Donate',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Category',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              ..._buildCategoryCheckboxes(),
              SizedBox(height: 20),
              _buildAdditionalItemsInput(),
              SizedBox(height: 10),
              _buildAddItemButton(),
              SizedBox(height: 10),
              Divider(
                color: Constants.blackColor.withOpacity(
                    0.45), // Change the color to your desired divider color
                thickness: 2.0, // Adjust the thickness of the divider
                height:
                    20.0, // Adjust the height between the text and the divider
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Donation Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor),
                ),
              ),
              SizedBox(height: 10),              
              Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        'Donation Method',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Constants.primaryColor),
                      ),
                      SizedBox(height: 10),
                      _buildDonationMethod(),
                    ],
                  )),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Weight',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Constants.primaryColor),
                        ),
                        SizedBox(height: 10),
                        _buildWeightUnit(),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 10),
              _buildWeightField(),
              SizedBox(height: 10),
              _buildPhotoField(),
              SizedBox(height: 10),
              Text(
                _donationMethod == 'Pick up'
                    ? 'Pick up Date and Time'
                    : 'Drop off Date and Time',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
               Row(
                children: [
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Constants.iconColor,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _buildDatePicker(context),
                  )),
                  SizedBox(width: 5),
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Constants.iconColor,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _buildTimePicker(context),
                  )),
                ], // Adjust the height between the text and the divider
              ),
              SizedBox(height: 10),
              Divider(),
              Visibility(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
                    children: [
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                              'Pick up Details',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Constants.primaryColor),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                            'Contact Number',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Constants.primaryColor),
                        ),
                        SizedBox(height: 10),
                        _buildContactNumberField(),
                        SizedBox(height: 20),
                        Text(
                            'Addresses',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Constants.primaryColor),
                        ),
                        SizedBox(height: 10),
                        _buildAddressDropdown(),
                    ],
                ),
                visible: _isPickup
              ),
              SizedBox(height: 30),
               SizedBox(height: 10), // Adjust as needed
              Visibility(
                  child: Column(children: [
                    Divider(
                      color: Constants.blackColor.withOpacity(
                          0.45), // Change the color to your desired divider color
                      thickness: 2.0, // Adjust the thickness of the divider
                      height:
                          20.0, // Adjust the height between the text and the divider
                    ),
                    SizedBox(height: 10),
                    Text(
                      'QR Code',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor),
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                    _buildQRCodeGenerator(context, 'Pending'),
                    SizedBox(height: 30),
                  ]),
                  visible: showQr),
              _buildDonateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryCheckboxes() {
    return _categoryIcons.entries.map((entry) {
      return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        secondary: entry.value,
        title: Text(entry.key),
        value: _categorySelections[entry.key],
        onChanged: (bool? value) {
          setState(() {
            _categorySelections[entry.key] = value!;
          });
        },
      );
    }).toList();
  }

  Widget _buildAdditionalItemsInput() {
    return TextFormField(
      controller: _textController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.more_horiz, color: Constants.iconColor),
        hintText: "Others...",
        hintStyle: const TextStyle(color: Color.fromARGB(175, 42, 46, 52)),
        labelText: 'Add new item',
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)),
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onFieldSubmitted: (value) {
        _addItem(value);
      },
    );
  }

  void _addItem(String value) {
    setState(() {
      if (!_categoryIcons.containsKey(value)) {
        _categoryIcons[value] =
            Icon(Icons.more_horiz, color: Constants.iconColor);
        _categorySelections[value] = false;
        _additionalItems.add(value);
        _textController.clear();
      }
    });
  }

  Widget _buildAddItemButton() {
    return Center( 
      child: ElevatedButton(
        onPressed: () {
          if (_textController.text.isNotEmpty) {
            _addItem(_textController.text);
          }
        },
        child: Text('Add Item', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
      ),
    );
  }

  // Center( 
  //       child: ElevatedButton(
  //         onPressed: _pickImageFromCamera,
  //         child: Text('Take Photo', style: TextStyle(color: Colors.white)),
  //         style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
  //       ),
  //     ),

  Widget _buildDonationMethod() {
    return ToggleButtons(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Constants.blackColor,
      selectedColor: Colors.white,
      fillColor: Constants.primaryColor,
      color: Constants.primaryColor,
      constraints: BoxConstraints(
        minHeight: 40.0,
        minWidth: MediaQuery.of(context).size.width / 4 - 20.0,
      ),
      isSelected: [_donationMethod == 'Pick up', _donationMethod == 'Drop off'],
      onPressed: (int index) {
        setState(() {
          _donationMethod = index == 0 ? 'Pick up' : 'Drop off';
          if (_donationMethod == 'Pick up') {
            _isPickup = true;
            showQr = false;
          } else {
            _isPickup = false;
          }
        });
      },
      children: const <Widget>[
        Text('Pick up'),
        Text('Drop off'),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: Constants.iconColor),
      title: Text('${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.access_time, color: Constants.iconColor),
      title: Text('${_selectedTime.format(context)}',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null && picked != _selectedTime) {
          setState(() {
            _selectedTime = picked;
          });
        }
      },
    );
  }

  Widget _buildWeightUnit() {
    return Row(
      children: [
        ToggleButtons(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: Constants.blackColor,
          selectedColor: Colors.white,
          fillColor: Constants.primaryColor,
          color: Constants.primaryColor,
          constraints:  BoxConstraints(
            minHeight: 40.0,
            minWidth: MediaQuery.of(context).size.width / 4 - 20.0,
          ),
          isSelected: [_weightUnit == 'lb', _weightUnit == 'kg'],
          onPressed: (int index) {
            setState(() {
             _weightUnit = index == 0 ? 'lb' : 'kg';
            });
          },
          children: const <Widget>[
            Text('lb'),
            Text('kg'),
          ],
        ),
      ],
    );
  }

  double _weightValue = 1.0;

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Value: ${_weightValue.toStringAsFixed(1)} $_weightUnit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.primaryColor),
        ),
        Slider(
          value: _weightValue,
          onChanged: (newValue) {
            setState(() {
              _weightValue = newValue;
            });
          },
          min: 1.0,
          max: 100.0,
          divisions: 100,
        ),
        if (_weightValidationMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _weightValidationMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  String? _weightValidationMessage;

  void _validateWeight() {
    setState(() {
      if (_weightValue <= 0.0) {
        _weightValidationMessage = 'Please enter a weight greater than zero';
      } else {
        _weightValidationMessage = null;
      }
    });
  }

  Widget _buildPhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Upload Photo',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor),
          ),
        ),
        _photo != null
            ? Image.file(_photo!)
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                height: 200,
                width: double.infinity,
                child: Icon(Icons.camera_alt, color: Colors.white70, size: 50),
              ),
        SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: _pickImageFromCamera,
            child: Text('Take Photo', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContactNumberField() {
    return TextFormField(
      controller: _contactController,
      decoration: InputDecoration(
        hintText: "+63",
        hintStyle: const TextStyle(color: Color.fromARGB(175, 42, 46, 52)),
        prefixIcon: Icon(Icons.phone, color: Constants.iconColor),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)),
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your contact number';
        }
        return null;
      },
    );
  }


  //   Widget _buildAddressDropdown() {
  //   return DropdownButtonFormField<String>(
  //     value: _selectedAddress,
  //     onChanged: (String? newValue) {
  //       setState(() {
  //         _selectedAddress = newValue;
  //       });
  //     },
  //     decoration: InputDecoration(
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(50),
  //         //color
  //         color: Constants.primaryColor,
  //       ),
  //     ),
  //     items: _addressOptions.map<DropdownMenuItem<String>>((String value) {
  //       return DropdownMenuItem<String>(
  //         value: value,
  //         child: Text(value),
  //       );
  //     }).toList(),
  //   );
  // }


Widget _buildAddressDropdown() {
  return DropdownButtonFormField<String>(
    value: _selectedAddress,
    onChanged: (String? newValue) {
      setState(() {
        _selectedAddress = newValue;
      });
    },
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(
          color: Constants.primaryColor, // Set border color here
        ),
      ),
      prefixIcon: Icon(
        Icons.location_on, // Set your desired icon here
        color: Constants.iconColor, // Set icon color here
      ),
    ),
    items: _addressOptions.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, style: TextStyle(color: Constants.primaryColor)),
      );
    }).toList(),
  );
}




  Widget _buildQRCodeGenerator(BuildContext context, status) {
    return Column(children: [
      Text("Present this QR Code to the organization for donation."),
      ListTile(
        title: _qrCodeData.isEmpty
            ? Text('No QR Code generated')
            : Column(
                children: [
                  QrImageView(
                    data: _qrCodeData,
                    version: QrVersions.auto,
                    size: 300.0,
                  ),
                  Text(_qrCodeData), // Display the QR code data as text
                  ElevatedButton(
                  onPressed: () {
                    // Function to download QR code
                    _downloadQRCode(context, _qrCodeData, status);
                    //pop
                  },
                  child: Text('Download QR Code'),
                ),
                ],
              ),
      ),
    ]);
  }



void _downloadQRCode(BuildContext context, String qrCodeData, String status) async {
  if (context == null) {
    print("Error: Null context provided");
    return;
  }

  try {
    // Create a white background
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, 300, 350), paint);

    // Generate QR code image
    final qrValidationResult = QrValidator.validate(
      data: qrCodeData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('QR Code generation failed');
    }
    final qrCode = qrValidationResult.qrCode;
    final qrPainter = QrPainter.withQr(
      qr: qrCode!,
      color: Colors.black,
      emptyColor: Colors.white,
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );

    final qrImageSize = 300.0;
    final offSet = (300 - qrImageSize) / 2;
    final qrImageRect = Rect.fromLTWH(offSet, offSet, qrImageSize, qrImageSize);
    qrPainter.paint(canvas, qrImageRect.size);

    // Overlay additional information
    final textStyle = ui.TextStyle(
      color: Colors.black,
      fontSize: 12.0,
    );
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: 12.0,
    ))
      ..pushStyle(textStyle)
      ..addText('Date Downloaded: ${DateTime.now().toString()} \nStatus: $status');
    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 300));
    canvas.drawParagraph(paragraph, const Offset(0, 310));

    // Convert canvas to image
    final generatedImage = await recorder.endRecording().toImage(300, 350);
    final byteDataWithText = await generatedImage.toByteData(format: ui.ImageByteFormat.png);
    final bytesWithText = byteDataWithText!.buffer.asUint8List();

    // Create a temporary file path
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String filePath = '$tempPath/qr_code_with_text.png';

    // Write the image bytes to a temporary file
    await File(filePath).writeAsBytes(bytesWithText);

    // Save the image to the photo gallery
    await GallerySaver.saveImage(filePath);

    // Show a toast or snackbar indicating successful download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR Code saved to gallery')),
    );
  } catch (e) {
    // Show error message if download fails
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save QR Code')),
    );
  }
}


  Widget _buildDonateButton(BuildContext context) {
  return Center(
    child: ElevatedButton(
      onPressed: () async {
        // Ensure that the selected organization is passed as an argument
        final UserModel? selectedOrganization =
            ModalRoute.of(context)?.settings.arguments as UserModel?;

        if (selectedOrganization == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No organization selected')));
          return;
        }

        DocumentReference donorRef = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid);
        DocumentReference orgRef = FirebaseFirestore.instance
            .collection('users')
            .doc(selectedOrganization.id);

        List<String> addresses = _addressControllers.map((controller) => controller.text.trim()).toList();

        if (_formKey.currentState!.validate()) {
          List<String> selectedCategories = _categorySelections.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

          List<File> photos = _photo != null ? [File(_photo!.path)] : [];

          if (selectedCategories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select at least one category')));
            return;
          }

          if (_weightValue == null || _weightValue <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a valid weight value')));
            return;
          }

          if (_selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a schedule date')));
            return;
          }

          DonationModel newDonation = DonationModel(
            donor: donorRef,
            organization: orgRef,
            categories: selectedCategories,
            weightValue: _weightValue,
            weightUnit: _weightUnit,
            isPickup: _isPickup,
            schedule: _selectedDate,
            status: 'Pending',
            qrCode: ' ',
            photos: photos.isNotEmpty ? photos.map((file) => file.path).toList() : null,
            addresses: _selectedAddress != null ? [_selectedAddress!] : null,
            contactNumber: _contactController.text.isNotEmpty ? _contactController.text : null,
            donationDrive: null,
            proofs: temp,
          );

          try {
            String donationId = await Provider.of<DonationsProvider>(context, listen: false)
                .addDonation(newDonation, photos);

            setState(() {
              _qrCodeData = donationId;
              if (!_isPickup) {
                showQr = true;
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Donation Successful')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add donation: $e')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please complete the form')));
        }
      },
      child: Text('Donate', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
      ),
    );
  }
}