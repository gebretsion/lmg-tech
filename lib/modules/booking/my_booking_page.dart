import 'package:flutter/material.dart';
import '../../data/services/customer_ops_service.dart';
import '../../core/localization/localization.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/booking.dart';
import 'booking_detail_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  MyBookingsPageState createState() => MyBookingsPageState();
}

class MyBookingsPageState extends State<MyBookingsPage> {
  List<Booking> bookings = [];
  bool loading = true;
  bool _isLoggedIn = false;

  // Keep track of the previous login state to detect changes.
  bool _previousIsLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check auth status when dependencies change (e.g., navigating between tabs).
    // This ensures the page updates correctly after login/logout.
    _checkAuthAndLoadBookings();
  }

  Future<void> _checkAuthAndLoadBookings() async {
    final token = await AuthService.getToken();
    _isLoggedIn = token != null;
    if (_isLoggedIn) {
      // Only load bookings if the user is logged in and wasn't before, or on initial load.
      if (!_previousIsLoggedIn) {
        loadBookings();
      }
    } else {
      // If the user is logged out, clear the bookings list.
      bookings.clear();
    }
    _previousIsLoggedIn = _isLoggedIn;
    if (mounted) setState(() => loading = false);
  }

 Future<void> loadBookings() async { // Made public
  setState(() => loading = true);

  try {
    final res = await CustomerOpsService.getMyBookings();
    if (mounted) {
      final List bookingsList = res['bookings'] ?? [];
      setState(() {
        // Safely parse bookings, handling potential errors in individual items
        bookings = bookingsList
            .whereType<Map<String, dynamic>>() // Ensure only maps are processed
            .map((b) {
              try { return Booking.fromJson(b); } catch (e) { debugPrint('Error parsing booking: $e, data: $b'); return null; }
            })
            .whereType<Booking>() // Filter out any nulls from failed parsing
            .toList();
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('my_bookings'))),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final localizations = AppLocalizations.of(context);
    if (loading) return const Center(child: CircularProgressIndicator());

    if (!_isLoggedIn) {
      return Center(child: Text(localizations.translate('please_login_for_bookings')));
    }

    if (bookings.isEmpty) return Center(child: Text(localizations.translate('no_bookings_yet')));

    return RefreshIndicator(
      onRefresh: loadBookings,
      child: ListView.builder(
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookingDetailPage(booking: booking)),
                          );
                        },
                        isThreeLine: true,
                      );
                    },
                  ),
    );
  }
}
