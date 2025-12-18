import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmg_app/modules/home/home_page.dart';
import '../../core/localization/localization.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> bookingResponse;

  const BookingConfirmationPage({super.key, required this.bookingResponse});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Safely extract data from the response
    final paymentReference = bookingResponse['paymentReference'] ?? 'N/A';
    final totalPrice = bookingResponse['totalPrice'] ?? 0.0;
    final currency = bookingResponse['currency'] ?? 'ETB';
    final accountNumber = bookingResponse['accountNumber'] ?? 'N/A';
    final message = bookingResponse['message'] ?? 'Booking created successfully.';
    final expiresAtRaw = bookingResponse['expiresAt'];
    
    String expiresAtFormatted = 'N/A';
    if (expiresAtRaw != null) {
      try {
        // Use DateFormat for reliable parsing and formatting
        final expiryDate = DateTime.parse(expiresAtRaw).toLocal();
        expiresAtFormatted = DateFormat.yMMMd().add_jm().format(expiryDate);
      } catch (e) {
        // Handle potential parsing errors
        expiresAtFormatted = 'Invalid Date';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('booking_successful')),
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              localizations.translate('payment_instructions'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildInfoCard(context, children: [
              _buildInfoRow(localizations.translate('payment_reference'), paymentReference),
              _buildInfoRow(localizations.translate('account_number'), accountNumber),
              _buildInfoRow(localizations.translate('total_amount'), '$totalPrice $currency'),
              _buildInfoRow(localizations.translate('payment_expires_at'), expiresAtFormatted),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 1)), // Go to My Bookings tab
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(localizations.translate('view_my_bookings')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}