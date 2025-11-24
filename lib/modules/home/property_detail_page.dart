import 'package:flutter/material.dart';
import 'package:lmg_app/data/services/auth_service.dart';
import 'package:lmg_app/core/localization/localization.dart';
import 'package:lmg_app/modules/auth/login_page.dart';
import 'package:lmg_app/modules/auth/register_page.dart';
import '../../data/models/property.dart';
import '../booking/property_booking_page.dart';
class PropertyDetailPage extends StatelessWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(localizations.translate('book_now')),
          onPressed: () async {
            final token = await AuthService.getToken();
            if (token == null) {
              // User is not logged in, show login/register dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(localizations.translate('authentication_required')),
                    content: Text(localizations.translate('auth_required_message')),
                    actions: <Widget>[
                      TextButton(
                        child: Text(localizations.translate('register')),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage(property: property)));
                        },
                      ),
                      TextButton(
                        child: Text(localizations.translate('login')),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(property: property)));
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // User is logged in, proceed to booking
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PropertyBookingPage(property: property)),
              );
            }
          },
        ),
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
            _buildDetailRow(localizations.translate('category'), property.category),
            _buildDetailRow(localizations.translate('status'), property.status),
            _buildDetailRow(localizations.translate('price_unit'), property.priceUnit.toString()),
            _buildDetailRow(localizations.translate('number_of_units'), property.numberOfProperty.toString()),
            const SizedBox(height: 16),
            Text(
              localizations.translate('rental_prices'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow(localizations.translate('per_hour'), '${property.rentalPrice['perHour'] ?? 'N/A'}'),
            _buildDetailRow(localizations.translate('per_day'), '${property.rentalPrice['perDay'] ?? 'N/A'}'),
            _buildDetailRow(localizations.translate('per_month'), '${property.rentalPrice['perMonth'] ?? 'N/A'}'),
            _buildDetailRow(localizations.translate('per_year'), '${property.rentalPrice['perYear'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            Text(
              localizations.translate('merchant_details'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow(localizations.translate('name'), property.merchant['name'] ?? 'N/A'),
            _buildDetailRow(localizations.translate('business_name'), property.merchant['businessName'] ?? 'N/A'),
            _buildDetailRow(localizations.translate('email'), property.merchant['email'] ?? 'N/A'),
            _buildDetailRow(localizations.translate('phone'), (property.merchant['phone'] ?? 'N/A').toString()),
            _buildDetailRow(localizations.translate('account_number'), (property.merchant['acountnumber'] ?? 'N/A').toString()),
            const SizedBox(height: 16),
            Text(
              localizations.translate('associated_bookings'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (property.bookings.isEmpty)
              Text(localizations.translate('no_current_bookings'))
            else
              // Use a non-scrolling ListView.builder for efficiency
              ListView.builder(
                shrinkWrap: true, // Important for nesting in a SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disable its own scrolling
                itemCount: property.bookings.length,
                itemBuilder: (context, index) {
                  final booking = property.bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(localizations.translate('booking_from_to').replaceAll('{startDate}', booking.startDate.split('T')[0]).replaceAll('{endDate}', booking.endDate.split('T')[0])),
                      subtitle: Text(localizations.translate('booking_status_units').replaceAll('{status}', booking.status).replaceAll('{units}', booking.numberOfProperty.toString())),
                    ),
                  );
                },
              ),
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
