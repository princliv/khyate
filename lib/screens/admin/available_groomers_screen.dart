import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/master_data_service.dart';

class AvailableGroomersScreen extends StatefulWidget {
  const AvailableGroomersScreen({super.key});

  @override
  State<AvailableGroomersScreen> createState() => _AvailableGroomersScreenState();
}

class _AvailableGroomersScreenState extends State<AvailableGroomersScreen> {
  final _adminService = AdminService();
  final _masterDataService = MasterDataService();
  
  DateTime? _selectedDate;
  String? _selectedTimeslotId;
  String? _selectedSubServiceId;
  List<dynamic> _timeslots = [];
  List<dynamic> _subServices = [];
  List<dynamic> _availableGroomers = [];
  bool _isLoading = false;
  bool _isForBooking = false;

  @override
  void initState() {
    super.initState();
    _loadSubServices();
    // TODO: Load timeslots from API
  }

  Future<void> _loadSubServices() async {
    try {
      final result = await _masterDataService.getAllCustomerServices();
      // Get subservices for each service
      // For now, using a placeholder - you may need to adjust based on your API
      setState(() {
        _subServices = result;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadAvailableGroomers() async {
    if (_selectedDate == null || _selectedTimeslotId == null || _selectedSubServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      
      final result = _isForBooking
          ? await _adminService.getAvailableGroomersForBooking(
              date: dateStr,
              timeslotId: _selectedTimeslotId!,
              subServiceId: _selectedSubServiceId!,
            )
          : await _adminService.getAvailableGroomers(
              date: dateStr,
              timeslotId: _selectedTimeslotId!,
              subServiceId: _selectedSubServiceId!,
            );
      
      setState(() {
        _availableGroomers = result?['groomers'] ?? result?['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading groomers: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Groomers'),
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
                      'Search Options',
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
                              _selectedDate != null
                                  ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                  : 'Select Date *',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: _selectedTimeslotId ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Timeslot ID *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter timeslot ID',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeslotId = value.isEmpty ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSubServiceId,
                      decoration: const InputDecoration(
                        labelText: 'Sub Service *',
                        border: OutlineInputBorder(),
                      ),
                      items: _subServices.map((service) {
                        return DropdownMenuItem<String>(
                          value: service['_id']?.toString() ?? service['id']?.toString(),
                          child: Text(service['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubServiceId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('For Booking'),
                      value: _isForBooking,
                      onChanged: (value) {
                        setState(() {
                          _isForBooking = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loadAvailableGroomers,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Search Available Groomers'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_availableGroomers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Groomers (${_availableGroomers.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availableGroomers.length,
                        itemBuilder: (context, index) {
                          final groomer = _availableGroomers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: groomer['profile_image'] != null
                                  ? NetworkImage(groomer['profile_image'])
                                  : null,
                              child: groomer['profile_image'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              '${groomer['first_name'] ?? ''} ${groomer['last_name'] ?? ''}',
                            ),
                            subtitle: Text(groomer['specialization'] ?? ''),
                            trailing: Text(
                              groomer['userStatus'] ?? 'N/A',
                              style: TextStyle(
                                color: groomer['userStatus'] == 'AVAILABLE'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
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

