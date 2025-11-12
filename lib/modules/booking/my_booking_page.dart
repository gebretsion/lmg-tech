import 'package:flutter/material.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/booking.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Booking> bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

 void _loadBookings() async {
  setState(() => loading = true);

  try {
    final res = await BookingService.getMyBookings();
    final List bookingsList = res['bookings'] ?? [];
    setState(() {
      bookings = bookingsList.map((b) => Booking.fromJson(b)).toList();
      loading = false;
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => loading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final booking = bookings[i];
                return ListTile(
                  leading: booking.imageUrls.isNotEmpty
                      ? Image.network(
                          booking.imageUrls.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(booking.assetName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${booking.status}\nTotal: \$${booking.totalPrice.toStringAsFixed(2)}\nBooked: ${booking.startDate.toLocal().toString().split(' ')[0]} to ${booking.endDate.toLocal().toString().split(' ')[0]}'),
                  isThreeLine: true,
                );
              },
            ),




    );
  }
}
