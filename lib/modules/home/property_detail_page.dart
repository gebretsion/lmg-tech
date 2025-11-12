import 'package:flutter/material.dart';
import '../../data/models/property.dart';

class PropertyDetailPage extends StatelessWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: property.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        property.imageUrls[index],
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              property.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              property.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Category:', property.category),
            _buildDetailRow('Status:', property.status),
            _buildDetailRow('Price Unit:', property.priceUnit),
            _buildDetailRow('Number of Units:', property.numberOfProperty.toString()),
            const SizedBox(height: 16),
            const Text(
              'Rental Prices:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Per Hour:', '${property.rentalPrice['perHour'] ?? 'N/A'}'),
            _buildDetailRow('Per Day:', '${property.rentalPrice['perDay'] ?? 'N/A'}'),
            _buildDetailRow('Per Month:', '${property.rentalPrice['perMonth'] ?? 'N/A'}'),
            _buildDetailRow('Per Year:', '${property.rentalPrice['perYear'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text(
              'Merchant Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Name:', property.merchant['name'] ?? 'N/A'),
            _buildDetailRow('Business Name:', property.merchant['businessName'] ?? 'N/A'),
            _buildDetailRow('Email:', property.merchant['email'] ?? 'N/A'),
            _buildDetailRow('Phone:', property.merchant['phone'] ?? 'N/A'),
            _buildDetailRow('Account Number:', property.merchant['acountnumber'] ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Associated Bookings:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (property.bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No current bookings for this property.'),
              )
            else
              ...property.bookings.map((booking) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('Booking from ${booking.startDate.split('T')[0]} to ${booking.endDate.split('T')[0]}'),
                    subtitle: Text('Status: ${booking.status} | Units: ${booking.numberOfProperty}'),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
