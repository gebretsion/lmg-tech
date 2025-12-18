import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lmg_app/data/services/api_service.dart';
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class CustomerOpsService {
  // ===================== GET PROPERTIES BY CATEGORY =====================
  static Future<Map<String, dynamic>> getPropertiesByCategory(String category) async {
    // This now matches the backend controller: GET /customer/properties?category=...
    return ApiService.getPublic('customer/properties?category=$category');
  }

  // ===================== GET PROPERTIES BY NAME (SEARCH) =====================
  static Future<Map<String, dynamic>> getPropertiesByName(String name) async {
    // This endpoint searches for properties by name across all categories.
    return ApiService.getPublic('customer/properties/search?name=${Uri.encodeComponent(name)}');
  }

  // ===================== GET MY BOOKINGS =====================
  static Future<Map<String, dynamic>> getMyBookings() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');
    return ApiService.get('customer/bookings', token: token);
  }

  // ===================== GET ALL BOOKINGS =====================
  static Future<Map<String, dynamic>> getAllBookings({String lang = 'en'}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');
    return ApiService.get('customer/bookings/all?lang=$lang', token: token);
  }

  // ===================== CREATE BOOKING =====================
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');
    return ApiService.post('booking/create', bookingData, token: token);
  }

  // ===================== DELETE BOOKING =====================
  static Future<dynamic> deleteBooking(dynamic bookingId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found. Please login first.');

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/bookings/$bookingId');
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {};
    }
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again.');
    }
    throw Exception('Failed to delete booking: ${response.body}');
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
    
    // Explicitly set the content type to ensure the backend recognizes it as an image
    final contentType = paymentProof.path.toLowerCase().endsWith('.png') 
        ? MediaType('image', 'png') 
        : MediaType('image', 'jpeg');

    request.files.add(await http.MultipartFile.fromPath(
      'paymentProof', 
      paymentProof.path,
      contentType: contentType,
    ));

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode == 401) throw Exception('Unauthorized: Please login again.');
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body);
    throw Exception('Failed to upload payment proof: ${res.body}');
  }

  // ===================== GET PROFILE =====================
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await AuthService.getToken(); // automatically retrieve saved token
    if (token == null) {
      throw Exception('No token found. Please login first.');
    }
    return ApiService.get('customer/profile', token: token);
  }

  // ===================== UPDATE PROFILE =====================
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phonenumber,
    String? address,
    File? profileImage,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No token found. Please login first.');
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/profile');
    var request = http.MultipartRequest('PATCH', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Add fields that are not null
    if (fullName != null) request.fields['fullName'] = fullName;
    if (email != null) request.fields['email'] = email;
    if (phonenumber != null) request.fields['phonenumber'] = phonenumber;
    if (address != null) request.fields['address'] = address;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage', // Corrected to match the backend controller's FileInterceptor
        profileImage.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      await ApiService.post('customer/profile', {}); // To trigger handler
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return jsonDecode(response.body);
    throw Exception('Failed to update profile: ${response.body}');
  }
}
