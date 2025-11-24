import 'package:flutter/material.dart';

class BookingForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;
  final List<Map<String, dynamic>> properties;

  const BookingForm({super.key, required this.onSubmit, required this.properties, this.isLoading = false});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPropertyId;
  final TextEditingController _numberOfProperty = TextEditingController();
  final TextEditingController _securityDeposit = TextEditingController();
  DateTime? _startDate;
  String? _propertyName;
  String? _merchantEmail;
  DateTime? _endDate;
  String _timeInterval = 'day';
  final List<String> intervals = ['hour', 'day', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    // If there's only one property, pre-select it.
    if (widget.properties.length == 1) {
      selectedPropertyId = widget.properties.first['_id'];
      _propertyName = widget.properties.first['name'];
      _merchantEmail = widget.properties.first['merchant']?['email'];
    }
  }

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
    } else if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start and end date.')),
      );
    } else if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before the start date.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? initialDate)
          : (_endDate ?? _startDate ?? initialDate),
      firstDate: isStart ? initialDate : (_startDate ?? initialDate),
      lastDate: DateTime(initialDate.year + 5),
    );

    if (pickedDate == null) return;

    final initialTime = TimeOfDay.fromDateTime(isStart
        ? (_startDate ?? initialDate)
        : (_endDate ?? _startDate ?? initialDate));
    final pickedTime =
        await showTimePicker(context: context, initialTime: initialTime);

    if (pickedTime == null) return;

    final finalDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);

    setState(() {
      if (isStart) {
        _startDate = finalDateTime;
        // If end date is before the new start date, clear it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = finalDateTime;
      }
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    // Format: YYYY-MM-DD HH:MM
    return dt.toLocal().toString().split('.')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.properties.length > 1)
            DropdownButtonFormField<String>(
              initialValue: selectedPropertyId,
              items: widget.properties
                  .map((p) => DropdownMenuItem<String>(
                        value: p['_id'].toString(),
                        child: Text('${p['name']} (${p['category']})'),
                      ))
                  .toSet()
                  .toList(),
              onChanged: (val) => setState(() => selectedPropertyId = val),
              decoration: const InputDecoration(labelText: 'Select Property'),
              validator: (v) => v == null ? 'Required' : null,
            )
          else if (_propertyName != null) ...[
            TextFormField(
              initialValue: _propertyName,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Property Name'),
            ),
            if (_merchantEmail != null)
              TextFormField(
                initialValue: _merchantEmail,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Merchant Email'),
              ),
          ],


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
                      ? 'Start Date & Time'
                      : _formatDateTime(_startDate)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _pickDate(isStart: false),
                  child: Text(_endDate == null
                      ? 'End Date & Time'
                      : _formatDateTime(_endDate)),
                ),
              ),
            ],
          ),
          DropdownButtonFormField(
            initialValue: _timeInterval,
            items: intervals
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (val) => setState(() => _timeInterval = val!),
            decoration: const InputDecoration(labelText: 'Time Interval'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('submit Book'),
          ),
        ],
      ),
    );
  }
}
