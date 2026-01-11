import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/subscription_service.dart';
import '../../services/master_data_service.dart';
import '../../services/trainer_service.dart';
import '../../widgets/searchable_dropdown.dart';

class SubscriptionManager extends StatefulWidget {
  @override
  State<SubscriptionManager> createState() => _SubscriptionManagerState();
}

class _SubscriptionManagerState extends State<SubscriptionManager> {
  final _subscriptionService = SubscriptionService();
  final _masterDataService = MasterDataService();
  final _trainerService = TrainerService();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _searchController = TextEditingController();
  
  File? _selectedMedia;
  String? _selectedCategoryId;
  String? _selectedTrainerId;
  String? _selectedSessionTypeId;
  String? _selectedAddressId; // LocationMaster ID
  List<String> _selectedDates = [];
  bool _isActive = true;
  bool _isSingleClass = false;
  
  List<dynamic> _categories = [];
  List<dynamic> _trainers = [];
  List<dynamic> _sessions = [];
  List<dynamic> _locations = []; // LocationMasters
  List<dynamic> _subscriptions = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTrainers();
    _loadSessions();
    _loadLocations();
    _loadSubscriptions();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _masterDataService.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadTrainers() async {
    try {
      final trainers = await _trainerService.getAllTrainers();
      if (mounted) {
        setState(() {
          _trainers = trainers;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadSessions() async {
    try {
      if (_selectedCategoryId != null) {
        final sessions = await _masterDataService.getSessionsByCategoryId(_selectedCategoryId!);
        if (mounted) {
          setState(() {
            _sessions = sessions;
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _masterDataService.getAllLocationMasters(page: 1, limit: 100);
      if (mounted) {
        setState(() {
          _locations = locations;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSubscriptions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _subscriptionService.getAllSubscriptions(
        page: _page,
        limit: _limit,
        categoryId: _selectedCategoryId,
        sessionTypeId: _selectedSessionTypeId,
        trainerId: _selectedTrainerId,
      );
      if (mounted) {
        setState(() {
          _subscriptions = result?['subscriptions'] ?? result?['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscriptions: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
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
      final dateStr = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        if (!_selectedDates.contains(dateStr)) {
          _selectedDates.add(dateStr);
        }
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _createSubscription() async {
    if (_nameController.text.isEmpty ||
        _selectedCategoryId == null ||
        _priceController.text.isEmpty ||
        _selectedTrainerId == null ||
        _selectedSessionTypeId == null ||
        _selectedAddressId == null ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate dates: 1 date for single class, 2 dates for multi-class
    if (_isSingleClass && _selectedDates.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Single class must have exactly one date')),
      );
      return;
    }

    if (!_isSingleClass && _selectedDates.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Multi-class must have exactly two dates (start and end)')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _subscriptionService.createSubscription(
        media: _selectedMedia,
        name: _nameController.text,
        categoryId: _selectedCategoryId!,
        price: double.parse(_priceController.text),
        trainer: _selectedTrainerId!,
        sessionType: _selectedSessionTypeId!,
        description: _descriptionController.text,
        isActive: _isActive,
        date: _selectedDates,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        addressId: _selectedAddressId!,
        isSingleClass: _isSingleClass,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription created successfully')),
        );
        
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        setState(() {
          _selectedMedia = null;
          _selectedCategoryId = null;
          _selectedTrainerId = null;
          _selectedSessionTypeId = null;
          _selectedAddressId = null;
          _selectedDates = [];
        });
        _loadSubscriptions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating subscription: ${e.toString()}')),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.fitness_center, color: Colors.purple, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Subscription',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add a new course or class',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade50,
                        ),
                        child: _selectedMedia != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(_selectedMedia!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add_photo_alternate, size: 48, color: Colors.purple),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to select media',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      prefixIcon: const Icon(Icons.title, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdown<Map<String, dynamic>>(
                    label: 'Category',
                    value: _selectedCategoryId,
                    items: _categories.cast<Map<String, dynamic>>(),
                    displayText: (cat) => cat['name'] ?? 'Unknown',
                    getValue: (cat) => cat['_id']?.toString() ?? cat['id']?.toString() ?? '',
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        _selectedSessionTypeId = null;
                      });
                      if (value != null) {
                        _masterDataService.getSessionsByCategoryId(value).then((sessions) {
                          if (mounted) {
                            setState(() {
                              _sessions = sessions;
                            });
                          }
                        });
                      }
                    },
                    isRequired: true,
                    prefixIcon: Icons.category,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price *',
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdown<Map<String, dynamic>>(
                    label: 'Trainer',
                    value: _selectedTrainerId,
                    items: _trainers.cast<Map<String, dynamic>>(),
                    displayText: (trainer) => '${trainer['first_name'] ?? ''} ${trainer['last_name'] ?? ''}'.trim(),
                    getValue: (trainer) => trainer['_id']?.toString() ?? trainer['id']?.toString() ?? '',
                    onChanged: (value) {
                      setState(() {
                        _selectedTrainerId = value;
                      });
                    },
                    isRequired: true,
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdown<Map<String, dynamic>>(
                    label: 'Session Type',
                    value: _selectedSessionTypeId,
                    items: _sessions.cast<Map<String, dynamic>>(),
                    displayText: (session) => session['sessionName'] ?? 'Unknown',
                    getValue: (session) => session['_id']?.toString() ?? session['id']?.toString() ?? '',
                    onChanged: (value) {
                      setState(() {
                        _selectedSessionTypeId = value;
                      });
                    },
                    isRequired: true,
                    prefixIcon: Icons.fitness_center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Address (LocationMaster) Dropdown with Search
                  SearchableDropdown<Map<String, dynamic>>(
                    label: 'Location/Address',
                    value: _selectedAddressId,
                    items: _locations.cast<Map<String, dynamic>>(),
                    displayText: (location) => location['streetName'] ?? location['name'] ?? 'Unknown Location',
                    getValue: (location) => location['_id']?.toString() ?? location['id']?.toString() ?? '',
                    onChanged: (value) {
                      setState(() {
                        _selectedAddressId = value;
                      });
                    },
                    isRequired: true,
                    prefixIcon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startTimeController,
                          decoration: InputDecoration(
                            labelText: 'Start Time *',
                            prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          readOnly: true,
                          onTap: () => _pickTime(_startTimeController),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _endTimeController,
                          decoration: InputDecoration(
                            labelText: 'End Time *',
                            prefixIcon: const Icon(Icons.access_time_filled, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          readOnly: true,
                          onTap: () => _pickTime(_endTimeController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Class Dates',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_selectedDates.length} date${_selectedDates.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.purple.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            label: const Text('Add Date'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        if (_selectedDates.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedDates.map((date) {
                              return Chip(
                                label: Text(date),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                backgroundColor: Colors.purple.shade50,
                                labelStyle: TextStyle(color: Colors.purple.shade900),
                                onDeleted: () {
                                  setState(() {
                                    _selectedDates.remove(date);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('Is Active', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: const Text('Make this subscription available for booking'),
                          value: _isActive,
                          activeColor: Colors.purple,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value ?? true;
                            });
                          },
                        ),
                        const Divider(),
                        CheckboxListTile(
                          title: const Text('Is Single Class', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: const Text('Check if this is a one-time class (requires 1 date)'),
                          value: _isSingleClass,
                          activeColor: Colors.purple,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _isSingleClass = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createSubscription,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_circle, size: 20),
                      label: Text(
                        _isLoading ? 'Creating...' : 'Create Subscription',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.list, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscriptions List',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'View and manage all subscriptions',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search subscriptions...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _loadSubscriptions,
                          icon: const Icon(Icons.search, size: 20),
                          label: const Text('Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _subscriptions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.subscriptions, size: 64, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No subscriptions found',
                                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _subscriptions.length,
                              itemBuilder: (context, index) {
                                final subscription = _subscriptions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.purple.shade50,
                                      ),
                                      child: subscription['media'] != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                subscription['media'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center, color: Colors.purple),
                                              ),
                                            )
                                          : const Icon(Icons.fitness_center, color: Colors.purple),
                                    ),
                                    title: Text(
                                      subscription['name'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Price: AED ${subscription['price'] ?? 'N/A'}',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            // TODO: Implement edit
                                          },
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            // TODO: Implement delete
                                          },
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

