import 'package:flutter/material.dart';
import '../../data/services/booking_service.dart';

class AllBookingsPage extends StatefulWidget {
  const AllBookingsPage({super.key});

  @override
  State<AllBookingsPage> createState() => _AllBookingsPageState();
}

class _AllBookingsPageState extends State<AllBookingsPage> {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
  setState(() => loading = true);

  try {
    final res = await BookingService.getAllBookings();
    setState(() {
      bookings = res['bookings'] ?? [];
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Bookings')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final booking = bookings[i];
                return ListTile(
                  title: Text(booking['propertyName']),
                  subtitle: Text('Status: ${booking['paymentProofPath'] != "no payment proven" ? "Paid" : "Pending"} | Start Date: ${booking['startDate']} | End Date: ${booking['endDate']}'),
                );
              },
            ),


    );
  }
}
