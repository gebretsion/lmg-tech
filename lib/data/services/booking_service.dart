import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class BookingService {
  // ===================== CREATE BOOKING =====================
  static Future<Map<String, dynamic>> createBooking({
    required String propertyId,
    required String startDate,
    required String endDate,
    required String timeInterval,
    required int numberOfProperty,
    double securityDeposit = 0,
    String lang = 'en',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/booking/create');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'propertyId': propertyId,
        'startDate': startDate,
        'endDate': endDate,
        'timeInterval': timeInterval,
        'numberOfProperty': numberOfProperty,
        'securityDeposit': securityDeposit,
        'lang': lang,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to create booking: ${res.body}');
    }
  }

  // ===================== GET MY BOOKINGS =====================
  static Future<Map<String, dynamic>> getMyBookings() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/bookings');
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch my bookings: ${res.body}');
    }
  }

  // ===================== GET ALL BOOKINGS =====================
  static Future<Map<String, dynamic>> getAllBookings() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/booking/all');
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch all bookings: ${res.body}');
    }
  }
}
