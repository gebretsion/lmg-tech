import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lmg_app/data/models/user.dart'; // Import the User model
import '../../core/config/app_config.dart';

const String _userKey = 'current_user';
const String _emailKey = 'saved_email';
const String _passwordKey = 'saved_password';
const String _rememberMeKey = 'remember_me';

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
        'profilePictureFile', // Ensure this matches the backend's expected field name
        profilePicture.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body); // Decode once
      if (data['token'] != null) await storeToken(data['token']);
      if (data['user'] != null) await saveUser(User.fromJson(data['user']));
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
      final data = jsonDecode(res.body); // Decode once
      if (data['token'] != null) await storeToken(data['token']);
      // Save user data
      if (data['user'] != null) {
        await saveUser(User.fromJson(data['user']));
      }
      // Save user data
      if (data['user'] != null) {
        await saveUser(User.fromJson(data['user']));
      }

      return data;
    } else {
      throw Exception('Failed to login: ${res.body}');
    }
  }
  
  // ===================== GOOGLE SIGN IN =====================
  static Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    // Adjust the endpoint if your backend uses a different path
    final uri = Uri.parse('${AppConfig.baseUrl}/customer/google-login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data['token'] != null) await storeToken(data['token']);
      if (data['user'] != null) await saveUser(User.fromJson(data['user']));
      return data;
    } else {
      throw Exception('Failed to login with Google: ${res.body}');
    }
  }

  // ===================== GET SAVED TOKEN =====================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ===================== STORE TOKEN =====================
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // ===================== SAVE USER DATA =====================
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // ===================== GET USER DATA =====================
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  // ===================== LOGOUT =====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // remove token on logout
    await prefs.remove(_userKey); // remove user data on logout
  }

  // ===================== SAVE LOGIN INFO =====================
  static Future<void> saveLoginInfo(String email, String password, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString(_emailKey, email);
      await prefs.setString(_passwordKey, password);
      await prefs.setBool(_rememberMeKey, true);
    } else {
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
      await prefs.setBool(_rememberMeKey, false);
    }
  }

  // ===================== GET LOGIN INFO =====================
  static Future<Map<String, dynamic>> getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_emailKey) ?? '',
      'password': prefs.getString(_passwordKey) ?? '',
      'rememberMe': prefs.getBool(_rememberMeKey) ?? false,
    };
  }
}
