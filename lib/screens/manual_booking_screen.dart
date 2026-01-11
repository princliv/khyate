import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/subservice_service.dart';
import '../services/master_data_service.dart';
import '../services/address_service.dart';

class ManualBookingScreen extends StatefulWidget {
  const ManualBookingScreen({super.key});

  @override
  State<ManualBookingScreen> createState() => _ManualBookingScreenState();
}

class _ManualBookingScreenState extends State<ManualBookingScreen> {
  final _bookingService = BookingService();
  final _subServiceService = SubServiceService();
  final _masterDataService = MasterDataService();
  final _addressService = AddressService();
  
  String? _selectedSubServiceId;
  String? _selectedTimeslotId;
  DateTime? _selectedDate;
  String? _selectedGroomerId;
  String? _selectedAddressId;
  final _petNameController = TextEditingController();
  String? _selectedWeightType;
  
  List<dynamic> _subServices = [];
  List<dynamic> _timeslots = [];
  List<dynamic> _groomers = [];
  List<dynamic> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubServices();
    _loadAddresses();
  }

  Future<void> _loadSubServices() async {
    try {
      final result = await _subServiceService.getAllSubServices();
      if (mounted) {
        setState(() {
          _subServices = result?['subservices'] ?? result?['data'] ?? [];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _addressService.getUserAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createBooking() async {
    if (_selectedSubServiceId == null ||
        _selectedTimeslotId == null ||
        _selectedDate == null ||
        _selectedGroomerId == null ||
        _selectedAddressId == null ||
        _petNameController.text.isEmpty ||
        _selectedWeightType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final bookingDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      
      await _bookingService.createManualBooking(
        subServiceId: _selectedSubServiceId!,
        timeslotId: _selectedTimeslotId!,
        bookingDate: bookingDate,
        groomerId: _selectedGroomerId!,
        addressId: _selectedAddressId!,
        petDetails: {
          'weightType': _selectedWeightType!,
          'petName': _petNameController.text,
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating booking: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Manual Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                // TODO: Load timeslots for selected subservice
              },
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
                          : 'Select Booking Date *',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _selectedGroomerId ?? ''),
              decoration: const InputDecoration(
                labelText: 'Groomer ID *',
                border: OutlineInputBorder(),
                hintText: 'Enter groomer ID',
              ),
              onChanged: (value) {
                setState(() {
                  _selectedGroomerId = value.isEmpty ? null : value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAddressId,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
              ),
              items: _addresses.map((address) {
                return DropdownMenuItem<String>(
                  value: address['_id']?.toString() ?? address['id']?.toString(),
                  child: Text(address['addressLine1'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAddressId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _petNameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedWeightType,
              decoration: const InputDecoration(
                labelText: 'Weight Type *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'small', child: Text('Small')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'large', child: Text('Large')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWeightType = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _petNameController.dispose();
    super.dispose();
  }
}

