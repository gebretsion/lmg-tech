import 'package:flutter/material.dart';
import '../../data/services/customer_ops_service.dart';
import 'package:lmg_app/modules/booking/create_booking_page.dart';

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create'),
            Tab(text: 'My Bookings'),
            Tab(text: 'All Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CreateBookingPage(), // token handled internally
          MyBookingsPage(),    // token handled internally
          AllBookingsPage(),   // token handled internally
        ],
      ),
    );
  }
}

// ================= MyBookingsPage =================
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with AutomaticKeepAliveClientMixin {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void fetchBookings() async {
    setState(() => loading = true);
    try {
      final res = await CustomerOpsService.getMyBookings(); // token fetched internally
      setState(() => bookings = res['bookings'] ?? []);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                child: ListTile(
                  title: Text(booking['assetName']),
                  subtitle: Text('From ${booking['startDate']} To ${booking['endDate']}'),
                ),
              );
            },
          );
  }
}

// ================= AllBookingsPage =================
class AllBookingsPage extends StatefulWidget {
  const AllBookingsPage({super.key});

  @override
  State<AllBookingsPage> createState() => _AllBookingsPageState();
}

class _AllBookingsPageState extends State<AllBookingsPage>
    with AutomaticKeepAliveClientMixin {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
  }

  void fetchAllBookings() async {
    setState(() => loading = true);
    try {
      final res = await CustomerOpsService.getAllBookings(); // token fetched internally
      setState(() => bookings = res['bookings'] ?? []);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                child: ListTile(
                  title: Text(booking['propertyName'] ?? booking['assetName']),
                  subtitle: Text('From ${booking['startDate']} To ${booking['endDate']}'),
                ),
              );
            },
          );
  }
}
