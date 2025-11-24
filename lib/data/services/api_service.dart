import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:lmg_app/data/services/auth_service.dart';
import '../../core/config/app_config.dart';

class ApiService {
  static Future<void> _handleUnauthorized() async {
    await AuthService.logout();
    // Here you might want to use a navigation service to redirect to the login screen
    // from anywhere in the app. For now, logging out will require app restart
    // or navigating back to a page that rebuilds auth state.
    throw Exception('Token expired or invalid. Please log in again.');
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    return _request('POST', endpoint, body: body, token: token);
  }
  /* static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  } */

  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    return _request('GET', endpoint, token: token);
  }
  /* static Future<Map<String, dynamic>> get(String endpoint,
      {String? token}) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  } */

  static Future<Map<String, dynamic>> getPublic(String endpoint) async {
    return _request('GET', endpoint);
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    try {
      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: jsonEncode(body));
      } else {
        response = await http.get(uri, headers: headers);
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      // Special handling for 404 in getPublic context
      if (endpoint.startsWith('customer/properties') && (response.statusCode == 404 || response.statusCode == 500)) {
        debugPrint(
            'API returned ${response.statusCode} for properties. Returning empty list.');
        return {'properties': []};
      }

      throw Exception('Request failed with status: ${response.statusCode}, body: ${response.body}');
    } catch (e) {
      // Re-throw exceptions from _handleUnauthorized or network errors
      rethrow;
    }
  }
  /* static Future<Map<String, dynamic>> getPublic(String endpoint) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    // Handle the case where a category has no properties.
    // The backend correctly returns 404, so we return an empty list instead of throwing an error.
    if (response.statusCode == 404 || response.statusCode == 500) {
      debugPrint('API returned ${response.statusCode}. Returning empty properties list.');
      return {'properties': []};
    }
    throw Exception('Request failed with status: ${response.statusCode}, body: ${response.body}');
  } */
}
