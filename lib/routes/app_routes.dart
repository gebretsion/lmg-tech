import 'package:flutter/material.dart';
import 'package:lmg_app/modules/auth/login_page.dart';
import 'package:lmg_app/modules/auth/register_page.dart';
import 'package:lmg_app/modules/booking/property_booking_page.dart';
import 'package:lmg_app/modules/home/home_page.dart';
//import 'package:lmg_app/modules/home/home_tab.dart';
import 'package:lmg_app/modules/home/property_detail_page.dart';
import 'package:lmg_app/data/models/property.dart';
import 'package:lmg_app/modules/booking/booking_detail_page.dart';
import 'package:lmg_app/data/models/booking.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String propertyDetail = '/property-detail';
  static const String propertyBooking = '/property-booking';
  static const String bookingDetail = '/booking-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case login:
        final property = settings.arguments as Property?;
        return MaterialPageRoute(
          builder: (_) => LoginPage(property: property),
        );
      
      case register:
        final property = settings.arguments as Property?;
        return MaterialPageRoute(
          builder: (_) => RegisterPage(property: property),
        );
      
      case propertyDetail:
        final property = settings.arguments as Property;
        return MaterialPageRoute(
          builder: (_) => PropertyDetailPage(property: property),
        );
      
      case propertyBooking:
        final property = settings.arguments as Property;
        return MaterialPageRoute(
          builder: (_) => PropertyBookingPage(property: property),
        );
      
      case bookingDetail:
        final booking = settings.arguments as Booking;
        return MaterialPageRoute(
          builder: (_) => BookingDetailPage(booking: booking),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper methods for common navigations
  static void goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  static void goToLogin(BuildContext context, {Property? property}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(property: property),
      ),
    );
  }

  static void goToRegister(BuildContext context, {Property? property}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterPage(property: property),
      ),
    );
  }

  static void goToPropertyDetail(BuildContext context, Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailPage(property: property),
      ),
    );
  }

  static void goToPropertyBooking(BuildContext context, Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyBookingPage(property: property),
      ),
    );
  }

  static void goToBookingDetail(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailPage(booking: booking),
      ),
    );
  }

  // Replace current route with home and specific tab
  static void goToHomeWithBookingTab(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 1)),
      (route) => false,
    );
  }
}