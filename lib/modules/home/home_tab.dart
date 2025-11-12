import 'package:flutter/material.dart';
import '../../data/services/customer_ops_service.dart';
import '../../data/models/property.dart';
import 'property_detail_page.dart'; // Import the new detail page

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> categories = [
    'EventSupply',
    'ConstructionEquipment',
    'HealthcareMedical',
    'other',
  ];
  String? selectedCategory;

  bool loading = false;
  List<Property> properties = [];

  void searchProperties(String category) async {
    setState(() => loading = true);

    try {
      final res = await CustomerOpsService.getPropertiesByCategory(category);
      final List propsList = res['properties'] ?? [];
      setState(() =>
          properties = propsList.map((p) => Property.fromJson(p)).toList());

      if (properties.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No properties found for this category.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching properties: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Properties')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedCategory = val);
                      if (val != null) searchProperties(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: selectedCategory == null
                      ? null
                      : () => searchProperties(selectedCategory!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: properties.isEmpty
                        ? const Center(child: Text('No properties available'))
                        : ListView.builder(
                            itemCount: properties.length,
                            itemBuilder: (context, index) {
                              final property = properties[index];
                              return Card(
                                child: ListTile(
                                  title: Text(property.name),
                                  subtitle: Text(
                                      '${property.category} - ${property.rentalPrice['perDay']} per day'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        child: const Text('Detail'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PropertyDetailPage(property: property),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
