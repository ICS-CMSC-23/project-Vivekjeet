// ignore_for_file: prefer_const_constructors, sort_child_properties_last

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

  final Map<String, Icon> _checkboxItems = {
    'Food': Icon(Icons.fastfood, color: Constants.iconColor),
    'Clothes': Icon(Icons.checkroom, color: Constants.iconColor),
    'Cash': Icon(Icons.attach_money, color: Constants.iconColor),
    'Necessities': Icon(Icons.shopping_cart, color: Constants.iconColor),
  };

  final Map<String, bool> _checkboxValues = {
    'Food': false,
    'Clothes': false,
    'Cash': false,
    'Necessities': false,
  };

  List<String> _additionalItems = [];
  String _donationMethod = 'Pick up';
  bool _isPickup = true;
  String _weightUnit = 'lb';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  List<String> _addresses = ['Address 1', 'Address 2', 'Address 3'];
  String _selectedAddress = 'Address 1';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.iconColor,
        title: const Text('Donor Donate',
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
              SizedBox(height: 20),
              Center(
                child: Text(
                  'What would you like to donate?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor),
                ),
              ),
              SizedBox(height: 10),
              ..._buildCheckboxes(),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              _buildDonationMethod(),
              SizedBox(height: 30),
              Text(
                _donationMethod == 'Pick up'
                    ? 'Choose Pick up Date and Time'
                    : 'Choose Drop off Date and Time',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              _buildDatePicker(context),
              _buildTimePicker(context),
              SizedBox(height: 10),
              Text(
                'Weight of Donations',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor),
              ),
              SizedBox(height: 10),
              _buildWeightUnit(),
              _buildWeightField(),
              SizedBox(height: 10),
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
                    _buildAddressDropdown(),
                  ]),
                  visible: _isPickup),
              SizedBox(height: 30),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCheckboxes() {
    return _checkboxItems.entries.map((entry) {
      return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        secondary: entry.value,
        title: Text(entry.key),
        value: _checkboxValues[entry.key],
        onChanged: (bool? value) {
          setState(() {
            _checkboxValues[entry.key] = value!;
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
      if (!_checkboxItems.containsKey(value)) {
        _checkboxItems[value] =
            Icon(Icons.more_horiz, color: Constants.iconColor);
        _checkboxValues[value] = false;
        _additionalItems.add(value);
        _textController.clear();
      }
    });
  }

  Widget _buildAddItemButton() {
    return ElevatedButton(
      onPressed: () {
        if (_textController.text.isNotEmpty) {
          _addItem(_textController.text);
        }
      },
      child: Text('Add Item', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
    );
  }

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
        Text('Weight unit: '),
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

  double _currentWeight = 0.0;

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight of Donations: ${_currentWeight.toStringAsFixed(1)} kg',
          style: TextStyle(fontSize: 16),
        ),
        Slider(
          value: _currentWeight,
          onChanged: (newValue) {
            setState(() {
              _currentWeight = newValue;
            });
          },
          min: 0.0,
          max: 100.0,
          divisions: 100,
          label: _currentWeight.toStringAsFixed(1),
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
      if (_currentWeight <= 0.0) {
        _weightValidationMessage = 'Please enter a weight greater than zero';
      } else {
        _weightValidationMessage = null;
      }
    });
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

  Widget _buildAddressDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAddress,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.location_on_outlined, color: Constants.iconColor),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)),
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF618264)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      items: _addresses.map((String address) {
        return DropdownMenuItem<String>(
          value: address,
          child: Text(address ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedAddress = newValue!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select an address';
        }
        return null;
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              //ADD DONATION TO DATABASE
              // Create an instance of DonationModel
              // DonationModel newDonation = DonationModel(
              //   donor: donorReference, // Assuming you have the donor reference
              //   organization:
              //       organizationReference, // Assuming you have the organization reference
              //   category: 'Clothing', // Example category
              //   weight: 5.0, // Example weight
              //   isPickup: true, // Example isPickup value
              //   schedule: DateTime.now(), // Example schedule
              //   status: 'Pending', // Example status
              //   qrCode: '12345', // Example qrCode
              //   // Add other necessary data
              // );

              // // Call the addDonation method from your provider
              // DonationsProvider().addDonation(newDonation);

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Donation Successful')));
            }
          },
          child: Text('Donate', style: TextStyle(color: Colors.white)),
          style:
              ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
        ),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState!.reset();
            _contactController.clear();
            _weightController.clear();
            setState(() {
              _checkboxValues.updateAll((key, value) => false);
              _additionalItems.clear();
              _donationMethod = 'Pick up';
              _weightUnit = 'lb';
              _selectedDate = DateTime.now();
              _selectedTime = TimeOfDay.now();
              _selectedAddress = _addresses[0];
            });
            //show snackbar
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Form Cleared')));
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          style:
              ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
        ),
      ],
    );
  }
}
