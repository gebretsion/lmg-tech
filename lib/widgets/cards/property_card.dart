import 'package:flutter/material.dart';
import 'package:lmg_app/core/localization/localization.dart';
import 'package:lmg_app/data/models/property.dart'; // make sure this matches your file

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onDetailTap;
  final VoidCallback? onBookNowTap;

  const PropertyCard({super.key, required this.property, this.onDetailTap, this.onBookNowTap});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (property.imageUrls.isNotEmpty)
            Image.network(
                property.imageUrls.first,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 120),
              )
          else
            Container(
              height: 120,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.home, size: 60, color: Colors.grey)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(property.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('Category: ${property.category}'),
                Text('Units Available: ${property.numberOfProperty}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onDetailTap,
                  child: Text(localizations.translate('detail')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onBookNowTap,
                  child: Text(localizations.translate('book_now')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
