import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/route_change_model.dart';
import '../../models/bus_model.dart';
import '../../services/notification_service.dart';
import '../../providers/bus_provider.dart';
import '../../theme/app_theme.dart';

class RouteChangeScreen extends StatefulWidget {
  final BusModel bus;

  const RouteChangeScreen({super.key, required this.bus});

  @override
  State<RouteChangeScreen> createState() => _RouteChangeScreenState();
}

class _RouteChangeScreenState extends State<RouteChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _newRoute = '';
  DateTime _effectiveTime = DateTime.now();
  final List<String> _affectedStops = [];
  final List<String> _newStops = [];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRouteChange() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newRoute.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a new route')),
      );
      return;
    }

    final routeChange = RouteChangeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      busId: widget.bus.id,
      busNumber: widget.bus.busNumber,
      originalRoute: widget.bus.routeName,
      newRoute: _newRoute,
      reason: _reasonController.text,
      effectiveTime: _effectiveTime,
      notificationTime: DateTime.now(),
      affectedStops: _affectedStops,
      newStops: _newStops,
    );

    final notificationService =
        Provider.of<NotificationService>(context, listen: false);

    try {
      await notificationService.notifyRouteChange(routeChange: routeChange);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route change notification sent successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Route'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Route Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Route',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.bus.routeName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Bus: ${widget.bus.busNumber}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // New Route Selection
              Text(
                'New Route',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _newRoute.isEmpty ? null : _newRoute,
                decoration: const InputDecoration(
                  labelText: 'Select New Route',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Route A', child: Text('Route A')),
                  DropdownMenuItem(value: 'Route B', child: Text('Route B')),
                  DropdownMenuItem(value: 'Route C', child: Text('Route C')),
                  DropdownMenuItem(
                      value: 'Alternative Route', child: Text('Alternative Route')),
                ],
                onChanged: (value) {
                  setState(() => _newRoute = value ?? '');
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a new route';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Route Change',
                  hintText: 'e.g., Road closure, Traffic, Emergency',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Effective Time
              Text(
                'Effective Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _effectiveTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_effectiveTime),
                    );
                    if (time != null) {
                      setState(() {
                        _effectiveTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'When will this change take effect?',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_effectiveTime.day}/${_effectiveTime.month}/${_effectiveTime.year} ${_effectiveTime.hour}:${_effectiveTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _submitRouteChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Send Route Change Notification',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.warningColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will notify all students and teachers tracking this bus.',
                        style: TextStyle(color: AppTheme.warningColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



