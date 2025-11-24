import 'package:flutter/material.dart';
import '../booking/my_booking_page.dart';
import '../booking/all_booking_page.dart';

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> with SingleTickerProviderStateMixin {
  final GlobalKey<MyBookingsPageState> _myBookingsKey = GlobalKey<MyBookingsPageState>();
  final GlobalKey<AllBookingsPageState> _allBookingsKey = GlobalKey<AllBookingsPageState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _myBookingsKey.currentState?.loadBookings();
        } else if (_tabController.index == 1) {
          _allBookingsKey.currentState?.loadBookings();
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Bookings'),
            Tab(text: 'All Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyBookingsPage(key: _myBookingsKey),
          AllBookingsPage(key: _allBookingsKey),
        ],
      ),
    );
  }
}
