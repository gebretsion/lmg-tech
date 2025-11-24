import 'package:flutter/material.dart';
import '../../data/models/booking.dart';

class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (booking.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: booking.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        booking.imageUrls[index],
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              booking.assetName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Booking ID:', booking.bookingId),
            _buildDetailRow('Category:', booking.category),
            _buildDetailRow('Number of Units:', booking.numberOfProperty.toString()),
            _buildDetailRow('Start Date:', booking.startDate.toLocal().toString().split(' ')[0]),
            _buildDetailRow('End Date:', booking.endDate.toLocal().toString().split(' ')[0]),
            _buildDetailRow('Total Price:', '\$${booking.totalPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Status:', booking.status),
            if (booking.paymentProofPath != null && booking.paymentProofPath!.isNotEmpty)
              _buildDetailRow('Payment Proof:', booking.paymentProofPath!),
            const SizedBox(height: 16),
            const Text(
              'Merchant Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Name:', booking.merchant['name'] ?? 'N/A'),
            _buildDetailRow('Business Name:', booking.merchant['businessName'] ?? 'N/A'),
            _buildDetailRow('Email:', booking.merchant['email'] ?? 'N/A'),
            _buildDetailRow('Phone:', (booking.merchant['phone'] ?? 'N/A').toString()),
            _buildDetailRow('Account Number:', (booking.merchant['acountnumber'] ?? 'N/A').toString()),
            const SizedBox(height: 16),
            const Text(
              'Booked By:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Name:', booking.bookedBy['name'] ?? 'N/A'),
            _buildDetailRow('Email:', booking.bookedBy['email'] ?? 'N/A'),
            _buildDetailRow('Phone:', (booking.bookedBy['phone'] ?? 'N/A').toString()),
          ],
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
