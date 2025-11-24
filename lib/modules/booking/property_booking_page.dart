import 'package:flutter/material.dart';
import 'package:lmg_app/data/models/property.dart';
import 'package:lmg_app/data/services/auth_service.dart';
import 'package:lmg_app/data/services/customer_ops_service.dart';
import 'package:lmg_app/modules/home/home_page.dart';
import 'package:lmg_app/widgets/forms/booking_form.dart';

class PropertyBookingPage extends StatefulWidget {
  final Property property;
  const PropertyBookingPage({super.key, required this.property});

  @override
  State<PropertyBookingPage> createState() => _PropertyBookingPageState();
}

class _PropertyBookingPageState extends State<PropertyBookingPage> {
  bool _isLoading = false;

  void _handleBooking(Map<String, dynamic> data) async {
    // Safeguard check for token before creating a booking
    final token = await AuthService.getToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a booking.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      // The createBooking method now expects a single Map object.
      final bookingData = {
        'assetName': widget.property.name,
        'merchantEmail': widget.property.merchant['email'],
        'startDate': DateTime.parse(data['startDate']).toIso8601String(),
        'endDate': DateTime.parse(data['endDate']).toIso8601String(),
        'timeInterval': data['timeInterval'],
        'numberOfProperty': data['numberOfProperty'],
        'securityDeposit': data['securityDeposit'],
      };
      final res = await CustomerOpsService.createBooking(bookingData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Booking completed successfully!')),
      );
      // Add a small delay so the user can read the success message
      await Future.delayed(const Duration(seconds: 1));

      // Navigate back to the HomePage and tell it to switch to the booking tab.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 1)), // 1 is the index for BookingTab
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.property.name}')),
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BookingForm(
                  // Pass the single property to the form
                  properties: [widget.property.toJson()],
                  isLoading: _isLoading,
                  onSubmit: _handleBooking,
                ),
              ),
            ),
    );
  }
}