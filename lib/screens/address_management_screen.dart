import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../services/master_data_service.dart';
import '../widgets/searchable_dropdown.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final AddressService _addressService = AddressService();
  final MasterDataService _masterDataService = MasterDataService();
  
  List<dynamic> _addresses = [];
  List<dynamic> _countries = [];
  List<dynamic> _cities = [];
  bool _isLoading = true;
  String _message = '';
  final Color _logoColor = const Color(0xFF20C8B1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final addresses = await _addressService.getAllAddresses();
      final countries = await _masterDataService.getAllCountries();
      
      setState(() {
        _addresses = addresses;
        _countries = countries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Failed to load addresses: ${e.toString()}';
      });
    }
  }

  Future<void> _loadCities(String countryId) async {
    try {
      final cities = await _masterDataService.getCitiesByCountry(countryId);
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to load cities: ${e.toString()}';
      });
    }
  }

  void _showAddAddressDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final pincodeController = TextEditingController();
    final streetController = TextEditingController();
    final flatNoController = TextEditingController();
    
    Map<String, dynamic>? selectedCountry;
    Map<String, dynamic>? selectedCity;
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Address'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name (e.g., Home, Work)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Pincode'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Street Address'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: flatNoController,
                    decoration: const InputDecoration(labelText: 'Flat No (Optional)'),
                  ),
                  const SizedBox(height: 10),
                  // Searchable Country Dropdown
                  SearchableDropdown<Map<String, dynamic>>(
                    label: 'Country',
                    items: _countries.cast<Map<String, dynamic>>(),
                    value: selectedCountry?['_id']?.toString() ?? selectedCountry?['id']?.toString(),
                    displayText: (country) => country['name'] ?? '',
                    getValue: (country) => country['_id']?.toString() ?? country['id']?.toString() ?? '',
                    onChanged: (value) {
                      setDialogState(() {
                        if (value != null && value.isNotEmpty) {
                          try {
                            selectedCountry = _countries.firstWhere(
                              (c) => (c['_id']?.toString() ?? c['id']?.toString()) == value,
                            ) as Map<String, dynamic>?;
                            selectedCity = null; // Reset city when country changes
                            _cities = []; // Clear cities list
                            _loadCities(value);
                          } catch (e) {
                            print('Error finding country: $e');
                            selectedCountry = null;
                          }
                        } else {
                          selectedCountry = null;
                          selectedCity = null;
                          _cities = [];
                        }
                      });
                    },
                    hintText: 'Select country',
                    isRequired: true,
                  ),
                  const SizedBox(height: 10),
                  // Searchable City Dropdown
                  SearchableDropdown<Map<String, dynamic>>(
                    label: 'City',
                    items: _cities.cast<Map<String, dynamic>>(),
                    value: selectedCity?['_id']?.toString() ?? selectedCity?['id']?.toString(),
                    displayText: (city) => city['name'] ?? '',
                    getValue: (city) => city['_id']?.toString() ?? city['id']?.toString() ?? '',
                    onChanged: selectedCountry != null ? (value) {
                      setDialogState(() {
                        if (value != null && value.isNotEmpty) {
                          try {
                            selectedCity = _cities.firstWhere(
                              (c) => (c['_id']?.toString() ?? c['id']?.toString()) == value,
                            ) as Map<String, dynamic>?;
                          } catch (e) {
                            print('Error finding city: $e');
                            selectedCity = null;
                          }
                        } else {
                          selectedCity = null;
                        }
                      });
                    } : (value) {
                      // No-op function when country is not selected
                    },
                    hintText: selectedCountry == null 
                        ? 'Please select a country first' 
                        : 'Select city',
                    isRequired: true,
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('Set as default address'),
                    value: isDefault,
                    onChanged: (value) {
                      setDialogState(() {
                        isDefault = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      pincodeController.text.isEmpty ||
                      streetController.text.isEmpty ||
                      selectedCountry == null ||
                      selectedCity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await _addressService.createAddress(
                      name: nameController.text,
                      phoneNumber: phoneController.text,
                      pincode: pincodeController.text,
                      street: streetController.text,
                      flatNo: flatNoController.text.isEmpty ? null : flatNoController.text,
                      cityId: selectedCity!['_id']?.toString() ?? selectedCity!['id']?.toString() ?? '',
                      countryId: selectedCountry!['_id']?.toString() ?? selectedCountry!['id']?.toString() ?? '',
                      isDefault: isDefault,
                    );
                    
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _logoColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Addresses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                Expanded(
                  child: _addresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No addresses saved',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _addresses.length,
                          itemBuilder: (context, index) {
                            final address = _addresses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Icon(Icons.location_on, color: _logoColor),
                                title: Text(
                                  address['name'] ?? 'Address',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (address['street'] != null)
                                      Text(address['street']),
                                    if (address['flat_no'] != null)
                                      Text('Flat: ${address['flat_no']}'),
                                    if (address['pin_code'] != null)
                                      Text('Pincode: ${address['pin_code']}'),
                                    if (address['phone_number'] != null)
                                      Text('Phone: ${address['phone_number']}'),
                                  ],
                                ),
                                trailing: address['make_default_address'] == true
                                    ? Chip(
                                        label: const Text('Default'),
                                        backgroundColor: _logoColor.withOpacity(0.2),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAddressDialog,
        backgroundColor: _logoColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

