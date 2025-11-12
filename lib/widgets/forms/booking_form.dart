import 'package:flutter/material.dart';

class BookingForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final List<Map<String, dynamic>> properties;

  const BookingForm({super.key, required this.onSubmit, required this.properties});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPropertyId;
  final TextEditingController _numberOfProperty = TextEditingController();
  final TextEditingController _securityDeposit = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _timeInterval = 'day';
  final List<String> intervals = ['hour', 'day', 'week', 'month', 'year'];

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        selectedPropertyId != null) {
      widget.onSubmit({
        'propertyId': selectedPropertyId,
        'numberOfProperty': int.parse(_numberOfProperty.text),
        'securityDeposit': double.tryParse(_securityDeposit.text) ?? 0,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'timeInterval': _timeInterval,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
  value: selectedPropertyId,
  items: widget.properties
      .where((p) => p['_id'] != null) // Filter out properties with null IDs
      .map((p) => DropdownMenuItem<String>(
            // The value for DropdownMenuItem cannot be null.
            value: p['_id'].toString(),
            child: Text('${p['name']} (${p['category']})'),
          ))
      .toList(),
  onChanged: (val) => setState(() => selectedPropertyId = val),
  decoration: const InputDecoration(labelText: 'Select Property'),
  validator: (v) => v == null ? 'Required' : null,
),


          TextFormField(
            controller: _numberOfProperty,
            decoration: const InputDecoration(labelText: 'Number of Property'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _securityDeposit,
            decoration: const InputDecoration(labelText: 'Security Deposit'),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _pickDate(isStart: true),
                  child: Text(_startDate == null
                      ? 'Start Date'
                      : _startDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _pickDate(isStart: false),
                  child: Text(_endDate == null
                      ? 'End Date'
                      : _endDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
            ],
          ),
          DropdownButtonFormField(
            value: _timeInterval,
            items: intervals
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (val) => setState(() => _timeInterval = val!),
            decoration: const InputDecoration(labelText: 'Time Interval'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _submit, child: const Text('Book')),
        ],
      ),
    );
  }
}
