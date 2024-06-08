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
// import 'package:qr_flutter/qr_flutter.dart';

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

  List<String> _addresses = [''];

  @override
  void initState() {
    super.initState();
    if (_addresses.isEmpty) {
      _addresses.add('');
    }
  }

  void addAddressField() {
    setState(() {
      _addresses.add('');
    });
  }

  void removeAddressField(int index) {
    if (index > 0) {
      setState(() {
        _addresses.removeAt(index);
      });
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              ..._buildCategoryCheckboxes(),
              SizedBox(height: 20),
              _buildAdditionalItemsInput(),
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
              Text(
                'Donation Method',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              _buildDonationMethod(),
              SizedBox(height: 10),
              Text(
                'Weight',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              _buildWeightUnit(),
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
              _buildDatePicker(context),
              _buildTimePicker(context),
              Divider(
                color: Constants.blackColor.withOpacity(
                    0.45), // Change the color to your desired divider color
                thickness: 2.0, // Adjust the thickness of the divider
                height:
                    20.0, // Adjust the height between the text and the divider
              ),
              Visibility(
                  child: Column(children: [
                    SizedBox(height: 10),
                    Text(
                      'Contact Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor),
                    ),
                    SizedBox(height: 10),
                    _buildContactNumberField(),
                    SizedBox(height: 10),
                    _buildAddressFields(),
                    SizedBox(height: 10),
                    _addAddressButton(),
                  ]),
                  visible: _isPickup),
              SizedBox(height: 30),
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
    return DropdownButton<String>(
      value: _donationMethod,
      onChanged: (String? newValue) {
        setState(() {
          _donationMethod = newValue!;
          if (_donationMethod == 'Pick up') {
            _isPickup = true;
          } else {
            _isPickup = false;
          }
        });
      },
      items: <String>['Pick up', 'Drop off'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      leading: Text('Date'),
      title: Text('${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
      trailing: Icon(Icons.calendar_today),
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
      leading: Text('Time'),
      title: Text('${_selectedTime.format(context)}'),
      trailing: Icon(Icons.access_time),
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
        Text('Unit: ',
              style: TextStyle(fontSize: 16),),
        DropdownButton<String>(
          value: _weightUnit,
          items: ['lb', 'kg'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _weightUnit = newValue!;
            });
          },
        ),
      ],
    );
  }

  double _weightValue = 0.0;

  Widget _buildWeightField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Value: ${_weightValue.toStringAsFixed(1)} $_weightUnit',
        style: TextStyle(fontSize: 16),
      ),
      Slider(
        value: _weightValue,
        onChanged: (newValue) {
          setState(() {
            _weightValue = newValue;
          });
        },
        min: 0.0,
        max: 100.0,
        divisions: 100,
        label: '${_weightValue.toStringAsFixed(1)} $_weightUnit',
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
          'Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.primaryColor),
        ),
      ),
      _photo != null
          ? Image.file(_photo!)
          : Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.camera_alt, color: Colors.white70, size: 50),
            ),
      Center( 
        child: ElevatedButton(
          onPressed: _pickImageFromCamera,
          child: Text('Take Photo', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
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

  Widget _buildAddressFields() {
    return Column(
      children: List.generate(_addresses.length, (index) {
        return Padding(
          padding: EdgeInsets.only(top: index > 0 ? 10 : 0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _addresses[index],
                  onChanged: (val) {
                    _addresses[index] = val;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.home, color: Constants.iconColor),
                    hintText: "Address ${index + 1}",
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
                ),
              ),
              if (index > 0)
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => removeAddressField(index),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _addAddressButton() {
    return ElevatedButton(
      onPressed: addAddressField,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Constants.primaryColor),
      ),
      child: Text('Add Address', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildDonateButton(BuildContext context) {
    return Center(
        child: ElevatedButton(
          onPressed: () {
            final UserModel selectedOrganization = ModalRoute.of(context)!.settings.arguments as UserModel;
            DocumentReference donorRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
            DocumentReference orgRef = FirebaseFirestore.instance.collection('users').doc(selectedOrganization.id);

            if (_formKey.currentState!.validate()) {
              List<String> selectedCategories = _categorySelections.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();

              List<File> photos = _photo != null ? [File(_photo!.path)] : [];

              DonationModel newDonation = DonationModel(
                donor: donorRef,
                organization: orgRef,
                categories: selectedCategories,
                weightValue: _weightValue,
                weightUnit: _weightUnit,
                isPickup: _isPickup,
                schedule: _selectedDate,
                status: 'Pending',
                qrCode: 'Sample QR Code',
                photos: photos.isNotEmpty ? photos.map((file) => file.path).toList() : null, 
                addresses: _addresses.isNotEmpty ? _addresses : null,  
                contactNumber: _contactController.text.isNotEmpty ? _contactController.text : null, 
              );

              Provider.of<DonationsProvider>(context, listen: false).addDonation(newDonation, photos);

              ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Donation Successful')));
            }
          },
          child: Text('Donate', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
        ),
    );
  }
}