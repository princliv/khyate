import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/master_data_service.dart';

class PlannerDashboardScreen extends StatefulWidget {
  const PlannerDashboardScreen({super.key});

  @override
  State<PlannerDashboardScreen> createState() => _PlannerDashboardScreenState();
}

class _PlannerDashboardScreenState extends State<PlannerDashboardScreen> {
  final _adminService = AdminService();
  final _masterDataService = MasterDataService();
  
  DateTime? _bookingDate;
  String? _selectedSubServiceId;
  List<dynamic> _subServices = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubServices();
  }

  Future<void> _loadSubServices() async {
    try {
      final result = await _masterDataService.getAllCustomerServices();
      // Extract subservices from services
      final subServicesList = <dynamic>[];
      if (result is List) {
        for (var service in result) {
          if (service['subServices'] is List) {
            subServicesList.addAll(service['subServices']);
          }
        }
      }
      setState(() {
        _subServices = subServicesList;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bookingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _bookingDate = picked;
      });
    }
  }

  Future<void> _loadDashboard() async {
    if (_bookingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select booking date')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bookingDateStr = "${_bookingDate!.year}-${_bookingDate!.month.toString().padLeft(2, '0')}-${_bookingDate!.day.toString().padLeft(2, '0')}";
      final result = await _adminService.getPlannerDashboard(
        bookingDate: bookingDateStr,
        subServiceId: _selectedSubServiceId,
      );
      setState(() {
        _dashboardData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Options',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            Text(
                              _bookingDate != null
                                  ? "${_bookingDate!.day}/${_bookingDate!.month}/${_bookingDate!.year}"
                                  : 'Booking Date *',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSubServiceId,
                      decoration: const InputDecoration(
                        labelText: 'Sub Service (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: _subServices.map((subService) {
                        return DropdownMenuItem<String>(
                          value: subService['_id']?.toString() ?? subService['id']?.toString(),
                          child: Text(subService['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubServiceId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loadDashboard,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Load Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_dashboardData != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard Data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Display dashboard data
                      ..._dashboardData!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value.toString(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

