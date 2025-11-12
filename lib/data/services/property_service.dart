import 'api_service.dart';
import '../models/property.dart';

class PropertyService {
  static Future<List<Property>> getPropertiesByCategory(
      String category, String token) async {
    final data =
        await ApiService.get('customer/properties?category=$category', token: token);

    final List props = data['properties'] ?? [];
    return props.map((p) => Property.fromJson(p)).toList();
  }
}
