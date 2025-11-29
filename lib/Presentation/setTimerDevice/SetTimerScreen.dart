import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smart_home_iotz/shared/variables/variables.dart';

class SetTimerScreen extends StatefulWidget {
  final String deviceId;
  const SetTimerScreen({super.key, required this.deviceId});

  @override
  State<SetTimerScreen> createState() => _SetTimerScreenState();
}

class _SetTimerScreenState extends State<SetTimerScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _actions = ['ON', 'OFF'];
  final List<String> _repeatTypes = ['Once', 'Daily', 'Weekly'];
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _selectedAction = 'ON';
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedRepeatType = 'Once';
  Set<String> _selectedDays = {};
  bool _isActive = true;
  bool _isSubmitting = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRepeatType == 'Weekly' && _selectedDays.isEmpty) return;

    setState(() => _isSubmitting = true);

    // Split deviceId: "Lumera:aMbosh-21"
    final dash = widget.deviceId.lastIndexOf('-');
    final espId =
        dash > 0 ? widget.deviceId.substring(0, dash) : widget.deviceId;
    final pin =
        dash > 0 ? int.tryParse(widget.deviceId.substring(dash + 1)) ?? 21 : 21;

    final payload = {
      "device_unit_id": espId,
      "pin": pin,
      "action": _selectedAction.toLowerCase(),
      "hour": _selectedTime.hour,
      "minute": _selectedTime.minute,
      "repeat_type": _selectedRepeatType,
      "days_of_week":
          _selectedRepeatType == 'Weekly' ? _selectedDays.join(',') : "",
      "is_active": _isActive,
    };

    try {
      final response = await http.post(
        Uri.parse(mySchedule),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Schedule created successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❗ Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeekly = _selectedRepeatType == 'Weekly';
    return Scaffold(
      appBar: AppBar(title: const Text('Set Device Timer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Device: ${widget.deviceId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments:
                  _actions
                      .map((a) => ButtonSegment(value: a, label: Text(a)))
                      .toList(),
              selected: {_selectedAction},
              onSelectionChanged:
                  (s) => setState(() => _selectedAction = s.first),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Time'),
              subtitle: Text('${_selectedTime.format(context)}'),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: _pickTime,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              value: _selectedRepeatType,
              items:
                  _repeatTypes
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
              onChanged:
                  (val) => setState(() => _selectedRepeatType = val ?? 'Once'),
            ),
            if (isWeekly) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children:
                    _days.map((day) {
                      final selected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_selectedDays.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Select at least one day',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Schedule'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed:
                  _isSubmitting || (isWeekly && _selectedDays.isEmpty)
                      ? null
                      : _submit,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
