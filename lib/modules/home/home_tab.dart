import 'package:flutter/material.dart';
import '../../data/services/customer_ops_service.dart';
import '../../core/localization/localization.dart';
import '../../data/models/property.dart';
import 'property_detail_page.dart'; // Import the new detail page

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'EventSupply', 'icon': Icons.celebration},
    {'name': 'ConstructionEquipment', 'icon': Icons.construction},
    {'name': 'HealthcareMedical', 'icon': Icons.medical_services},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];
  String? selectedCategory;

  bool loading = false;
  List<Property> properties = [];

  void searchProperties(String category) async {
    setState(() => loading = true);

    try {
      final res = await CustomerOpsService.getPropertiesByCategory(category); // Use guest-accessible method
      debugPrint('API Response for $category: $res'); // Added for debugging
      final List<dynamic> propsList = res['properties'] ?? [];
      // Filter out any non-Map items before mapping to Property objects
      final List<Property> parsedProperties = propsList
          .whereType<Map<String, dynamic>>()
          .map((p) => Property.fromJson(p))
          .toList();

      setState(() {
        properties = parsedProperties;
      });
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('could_not_fetch_properties'))),
      );
    } finally { 
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // If no category is selected, show the main home screen.
    if (selectedCategory == null) {
      return _buildMainHome();
    } else {
      // If a category is selected, show the properties list for that category.
      return _buildPropertiesList();
    }
  }

  // Widget for the main home screen with categories
  Widget _buildMainHome() {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '  ${localizations.translate('welcome_to_lmg')}',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: localizations.translate('search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder( // Use LayoutBuilder for better performance in complex layouts
                builder: (context, constraints) => GridView.count(
                  crossAxisCount: 2, // Two columns
                  crossAxisSpacing: 16, // Spacing between columns
                  mainAxisSpacing: 16, // Spacing between rows
                  childAspectRatio: 1.5, // Adjust aspect ratio for button size
                  children: categories.map((categoryMap) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        setState(() => selectedCategory = categoryMap['name'] as String);
                        searchProperties(categoryMap['name'] as String);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(categoryMap['icon'] as IconData, size: 30),
                          const SizedBox(height: 8),
                          Text(categoryMap['name'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for displaying the list of properties for the selected category.
  Widget _buildPropertiesList() {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory ?? localizations.translate('properties')),
        // Back button to return to the main home screen.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedCategory = null;
              properties = []; // Clear properties when going back
            });
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? Center(child: Text(localizations.translate('no_properties_available')))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return Card(
                      child: ListTile(
                        title: Text(property.name),
                        subtitle: Text(
                            '${property.category} - ${property.rentalPrice['perDay']} per day'),
                        trailing: ElevatedButton(
                          child: Text(localizations.translate('detail')),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailPage(property: property),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
