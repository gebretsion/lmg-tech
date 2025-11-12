import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class CustomerOpsService {
  // ===================== GET PROPERTIES BY CATEGORY =====================
  static Future<Map<String, dynamic>> getPropertiesByCategory(String category) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/properties?category=$category');
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
      throw Exception('Failed to fetch properties: ${res.body}');
    }
  }

  // ===================== GET MY BOOKINGS =====================
  static Future<Map<String, dynamic>> getMyBookings() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/bookings');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
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

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/bookings/all');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch all bookings: ${res.body}');
    }
  }

  // ===================== CREATE BOOKING =====================
  static Future<Map<String, dynamic>> createBooking({
    required String assetName,
    required String merchantEmail,
    required DateTime startDate,
    required DateTime endDate,
    required String timeInterval,
    required int numberOfProperty,
    double securityDeposit = 0,
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
        'assetName': assetName,
        'merchantEmail': merchantEmail,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'timeInterval': timeInterval,
        'numberOfProperty': numberOfProperty,
        'securityDeposit': securityDeposit,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to create booking: ${res.body}');
    }
  }

  // ===================== UPLOAD PAYMENT PROOF =====================
  static Future<Map<String, dynamic>> uploadPaymentProof({
    required String bookingId,
    required File paymentProof,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/bookings/$bookingId/payment-proof');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('paymentProof', paymentProof.path));

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to upload payment proof: ${res.body}');
    }
  }
}
