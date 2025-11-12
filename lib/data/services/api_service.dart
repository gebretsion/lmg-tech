import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> post(
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
  }

  static Future<Map<String, dynamic>> get(String endpoint,
      {String? token}) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}
