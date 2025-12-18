import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../data/models/booking.dart';
import '../../data/services/customer_ops_service.dart';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
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
            _buildDetailRow('Start Date & Time:', booking.startDate.toLocal().toString().substring(0, 16)),
            _buildDetailRow('End Date & Time:', booking.endDate.toLocal().toString().substring(0, 16)),
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
            const SizedBox(height: 24),
            Center(
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _uploadPaymentProof(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose File (Upload Receipt)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
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

  Future<void> _uploadPaymentProof(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final File file = File(pickedFile.path);
        final res = await CustomerOpsService.uploadPaymentProof(
          bookingId: widget.booking.bookingId,
          paymentProof: file,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Uploaded successfully')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }
}
