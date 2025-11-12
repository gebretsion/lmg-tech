import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class AuthService {
  // ===================== REGISTER =====================
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phonenumber,
    required String acountnumber,
    required String address,
    File? profilePicture,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/customer/register');
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['fullName'] = fullName;
    request.fields['phonenumber'] = phonenumber;
    request.fields['acountnumber'] = acountnumber;
    request.fields['address'] = address;

    if (profilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        profilePicture.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // ===================== LOGIN =====================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/customer/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);

      // Save token in shared preferences
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
      }

      return data;
    } else {
      throw Exception('Failed to login: ${res.body}');
    }
  }
  
  // ===================== GET SAVED TOKEN =====================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ===================== GET PROFILE =====================
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken(); // automatically retrieve saved token
    if (token == null) {
      throw Exception('No token found. Please login first.');
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/customer/profile');
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
      throw Exception('Failed to fetch profile: ${res.body}');
    }
  }

  // ===================== LOGOUT =====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // remove token on logout
  }
}
