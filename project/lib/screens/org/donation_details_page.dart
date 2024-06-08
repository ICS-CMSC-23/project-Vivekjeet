import 'package:flutter/material.dart';
import 'package:project/models/donation_model.dart';
import 'package:project/providers/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.donation.status;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            _buildDetailRow('Weight:', '${widget.donation.weightValue} ${widget.donation.weightUnit}'),
            _buildDetailRow('Mode:', widget.donation.isPickup ? 'Pickup' : 'Dropoff'),
            _buildDetailRow('Schedule:', widget.donation.schedule.toString()),
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
                'Complete',
                'Canceled',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                  context.read<DonationsProvider>().updateStatus(widget.donation.donationId, _selectedStatus);
                });
              },
            ),
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
