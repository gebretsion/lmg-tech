import 'package:flutter/material.dart';
import 'package:lmg_app/data/models/property.dart'; // make sure this matches your file

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          property.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(property.description ?? 'No description'),
            const SizedBox(height: 4),
            Text('Category: ${property.category}'),
            Text('Units Available: ${property.numberOfProperty}'),
            
          ],
        ),
        onTap: onTap,
        trailing: property.imageUrls != null && property.imageUrls!.isNotEmpty
            ? Image.network(
                property.imageUrls!.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.home),
      ),
    );
  }
}
