import 'package:flutter/material.dart';
import '../../data/services/customer_ops_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/property.dart';
import '../../widgets/forms/booking_form.dart';

class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({super.key});

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  List<Property> properties = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

    void fetchProperties() async {
    setState(() => loading = true);
    try {
      // Fetch properties and parse them into a list of Property objects.
      final res = await CustomerOpsService.getPropertiesByCategory('EventSupply');
      final List propertiesJson = res['properties'] ?? [];
      setState(() => properties = propertiesJson.map((p) => Property.fromJson(p)).toList());

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(content: Text('Error fetching properties: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void handleBooking(Map<String, dynamic> data) async {
    if (data['propertyId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a property first.')),
      );
      return;
    }

    try {
      final res = await BookingService.createBooking(
        propertyId: data['propertyId'],
        startDate: data['startDate'],
        endDate: data['endDate'],
        timeInterval: data['timeInterval'],
        numberOfProperty: data['numberOfProperty'],
        securityDeposit: data['securityDeposit'],
        lang: 'en',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Booking completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Booking')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Convert the list of Property objects to the Map format expected by the form.
                child: BookingForm(
                  properties: properties.map((p) => {
                    '_id': p.id, // Ensure your Property model has an 'id' field.
                    'name': p.name,
                    'category': p.category,
                  }).toList(),
                  onSubmit: handleBooking,
                ),
              ),
            ),
    );
  }
}
