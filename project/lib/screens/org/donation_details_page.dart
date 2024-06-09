import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/donation_model.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony/telephony.dart';

class DonationDetailsPage extends StatefulWidget {
  final DonationModel donation;
  final Map<String, dynamic> donorData;

  const DonationDetailsPage({Key? key, required this.donation, required this.donorData}) : super(key: key);

  @override
  _DonationDetailsPageState createState() => _DonationDetailsPageState();
}

class _DonationDetailsPageState extends State<DonationDetailsPage> {
  late String _selectedStatus;
  late PageController _pageController;
  bool _isCompletedStatus = false;
  List<File> _uploadedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.donation.status;
    _pageController = PageController();
    _isCompletedStatus = _selectedStatus == 'Completed';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _uploadedPhotos.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _uploadedPhotos.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.donation.photos!.isNotEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: widget.donation.photos!.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.donation.photos![index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: widget.donation.photos!.length,
                          effect: const WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: Colors.green,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Image.asset(
                          'images/login_logo.png',
                          fit: BoxFit.cover,
                          height: 150,
                          width: 150,
                        ),
                        const Text(
                          'No photos attached.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSectionTitle('Donation Details'),
            _buildDetailRow('Category:', widget.donation.categories.join(', ')),
            _buildDetailRow('Weight:', '${widget.donation.weightValue.toStringAsFixed(2)} ${widget.donation.weightUnit}'),
            _buildDetailRow('Mode:', widget.donation.isPickup ? 'Pickup' : 'Dropoff'),
            _buildDetailRow('Schedule:', DateFormat('MMMM d, yyyy hh:mm a').format(widget.donation.schedule)),
            if (widget.donation.isPickup) ...[
              _buildDetailRow('Contact Number:', widget.donation.contactNumber ?? 'N/A'),
              _buildDetailRow('Addresses:', widget.donation.addresses?.join(', ') ?? 'N/A'),
            ],
            const SizedBox(height: 16),
            _buildSectionTitle('Status'),
            DropdownButton<String>(
              value: _selectedStatus,
              items: <String>[
                'Pending',
                'Confirmed',
                'Scheduled for Pick-up',
                'Completed',
                'Cancelled',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _isCompletedStatus ? null : (String? newValue) {
                setState(() {
                  if (newValue == 'Completed' && _uploadedPhotos.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload photos before marking as Completed.'),
                      ),
                    );
                  } else {
                    _selectedStatus = newValue!;
                    _isCompletedStatus = _selectedStatus == 'Completed';
                    context.read<DonationsProvider>().updateStatus(widget.donation.donationId, _selectedStatus);
                  }
                });
              },
            ),
              const SizedBox(height: 16),
              if (!_isCompletedStatus) ...[
              _buildSectionTitle('Upload Photos as Proofs'),
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
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _uploadedPhotos.asMap().entries.map((entry) {
                  final index = entry.key;
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
                            _removeImage(index);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: ()  {
                    context.read<DonationsProvider>().uploadProofs(widget.donation.donationId, _uploadedPhotos);

                    // Update status to "Complete"
                    context.read<DonationsProvider>().updateStatus(widget.donation.donationId, 'Completed');

                    // Show Snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uploaded successfully'),
                      ),
                    );

                    String message = "Hello, ${widget.donorData['name']}! Your donation has arrived to its destination.";                      
                    try{
                      telephony.sendSms(
                        to: widget.donorData['contactNumber'],
                        message: message.trim()
                      );
                    } catch (e) {
                      print("Error: $e");
                    }

                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color?>(
                      const Color(0xFF618264),
                    ),
                  ),
                   child: const Text(
                    'Upload',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            const Divider(),
            _buildSectionTitle('Donor Details'),
            _buildDetailRow('Username:', widget.donorData['userName']),
            _buildDetailRow('Name:', widget.donorData['name']),
            _buildDetailRow('Contact Number:', widget.donorData['contactNumber']),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF618264),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
