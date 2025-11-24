import 'package:flutter/material.dart';
import '../../data/services/customer_ops_service.dart';

class AllBookingsPage extends StatefulWidget {
  const AllBookingsPage({super.key});

  @override
  AllBookingsPageState createState() => AllBookingsPageState();
}

class AllBookingsPageState extends State<AllBookingsPage> {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  void loadBookings() async {
  setState(() => loading = true);

  try {
    final res = await CustomerOpsService.getAllBookings();
    if (mounted) {
      setState(() {
        bookings = res['bookings'] ?? [];
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => loading = false);
    }
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
                  leading: (booking['imageUrls'] as List).isNotEmpty
                      ? Image.network(
                          (booking['imageUrls'] as List).first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(booking['propertyName'] ?? 'N/A'),
                  subtitle: Text('Status: ${booking['paymentProofPath'] != "no payment proven" ? "Paid" : "Pending"}\nBooked: ${booking['startDate'].split('T')[0]} to ${booking['endDate'].split('T')[0]}'),
                  isThreeLine: true,
                );
              },
            ),


    );
  }
}
