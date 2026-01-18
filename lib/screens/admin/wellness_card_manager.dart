import 'package:Outbox/screens/purchase_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/subscription_service.dart';
import '../../services/master_data_service.dart';
import '../../services/trainer_service.dart';
import '../../utils/asset_to_file_helper.dart';

class WellnessCardManager extends StatefulWidget {
  @override
  State<WellnessCardManager> createState() => _WellnessCardManagerState();
}

class _WellnessCardManagerState extends State<WellnessCardManager> {
  final _subscriptionService = SubscriptionService();
  final _masterDataService = MasterDataService();
  final _trainerService = TrainerService();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _searchController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  
  File? _selectedMedia;
  bool _useMediaUrl = false;
  String? _selectedCategoryId;
  String? _selectedTrainerId;
  String? _selectedSessionTypeId;
  String? _selectedAddressId;
  final _manualAddressIdController = TextEditingController();
  bool _useManualAddress = false;
  List<String> _selectedDates = [];
  bool _isActive = true;
  bool _isSingleClass = false;
  
  List<dynamic> _categories = [];
  List<dynamic> _trainers = [];
  List<dynamic> _sessions = [];
  List<dynamic> _locations = [];
  List<dynamic> _subscriptions = [];
  bool _isLoading = false;
  bool _isLoadingLocations = false;
  int _page = 1;
  final int _limit = 10;
  String? _wellnessCategoryId;

  @override
  void initState() {
    super.initState();
    _loadDefaultMedia();
    _loadCategories();
    _loadTrainers();
    // Load locations asynchronously after other data loads
    Future.microtask(() => _loadLocations());
    _loadSubscriptions();
  }

  Future<void> _loadDefaultMedia() async {
    // Pre-load default image as File for faster submission
    if (_selectedMedia == null) {
      final file = await AssetToFileHelper.assetToFile(
        'assets/default_thumbnail.webp',
        fileName: 'default_thumbnail_wellness.webp',
      );
      if (file != null && mounted) {
        setState(() {
          _selectedMedia = file;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _masterDataService.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          // Find wellness category (case-insensitive search)
          // Prioritize exact "wellness" match, exclude anything with "fitness"
          try {
            final wellnessCategory = categories.firstWhere(
              (cat) {
                final categoryName = (cat['cName']?.toString().toLowerCase() ?? '').trim();
                return categoryName.contains('wellness') && !categoryName.contains('fitness');
              },
            );
            _wellnessCategoryId = wellnessCategory['_id']?.toString() ?? wellnessCategory['id']?.toString();
            _selectedCategoryId = _wellnessCategoryId;
            print('Wellness Card Manager: Found wellness category ID: $_wellnessCategoryId');
            if (_wellnessCategoryId != null) {
              _loadSessions();
            }
          } catch (e) {
            // Wellness category not found, user can select manually
            print('Wellness category not found: $e');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: ${e.toString()}')),
        );
      }
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
    if (_isLoadingLocations) return; // Prevent multiple simultaneous loads
    
    if (!mounted) return;
    setState(() {
      _isLoadingLocations = true;
    });
    
    try {
      // Reduced limit to 50 for faster initial load
      final locations = await _masterDataService.getAllLocationMasters(
        page: 1, 
        limit: 50,
      );
      if (mounted) {
        setState(() {
          _locations = locations;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading locations: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadSubscriptions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _subscriptionService.getAllSubscriptions(
        page: _page,
        limit: _limit,
        categoryId: _wellnessCategoryId,
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
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedMedia = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a price')),
      );
      return;
    }

    if (_selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trainer')),
      );
      return;
    }

    if (_selectedSessionTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a session type')),
      );
      return;
    }

    if ((_selectedAddressId == null || _selectedAddressId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_useManualAddress 
          ? 'Please enter a location ID' 
          : 'Please select an address/location')),
      );
      return;
    }

    if (_startTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start time')),
      );
      return;
    }

    if (_endTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end time')),
      );
      return;
    }

    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one date')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

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

    // Handle image: either file upload or URL
    File? mediaToUpload;
    String? mediaUrl;
    
    if (_useMediaUrl) {
      // Use URL if provided
      if (_mediaUrlController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an image URL or switch to file upload')),
        );
        return;
      }
      mediaUrl = _mediaUrlController.text.trim();
    } else {
      // Use file upload or default image
      mediaToUpload = _selectedMedia;
      if (mediaToUpload == null) {
        mediaToUpload = await AssetToFileHelper.assetToFile(
          'assets/default_thumbnail.webp',
          fileName: 'default_thumbnail_wellness.webp',
        );
        
        if (mediaToUpload == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not load default image. Please select an image manually.')),
          );
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // ENFORCE wellness category - MUST use _wellnessCategoryId
      if (_wellnessCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wellness category not found. Please ensure a wellness category exists in the system.')),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      // Double-check selected category is wellness (prevent user from selecting wrong category)
      if (_selectedCategoryId != null && _selectedCategoryId != _wellnessCategoryId) {
        final selectedCat = _categories.firstWhere(
          (cat) => (cat['_id']?.toString() ?? cat['id']?.toString()) == _selectedCategoryId,
          orElse: () => {},
        );
        final categoryName = (selectedCat['cName'] ?? '').toString().toLowerCase();
        if (!categoryName.contains('wellness') || categoryName.contains('fitness')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only wellness categories are allowed. Using wellness category.')),
          );
        }
      }
      
      await _subscriptionService.createSubscription(
        media: mediaToUpload,
        mediaUrl: mediaUrl,
        name: _nameController.text.trim(),
        categoryId: _wellnessCategoryId!, // ALWAYS use wellness category ID (strictly enforced)
        price: price,
        trainer: _selectedTrainerId!,
        sessionType: _selectedSessionTypeId!,
        description: _descriptionController.text.trim(),
        isActive: _isActive,
        date: _selectedDates,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        addressId: _selectedAddressId!,
        isSingleClass: _isSingleClass,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wellness subscription created successfully')),
        );
        
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        setState(() {
          // Keep wellness category selected - don't reset it
          // _selectedCategoryId stays as wellness category
          _selectedTrainerId = null;
          _selectedSessionTypeId = null;
          _selectedAddressId = null;
          _useManualAddress = false;
          _selectedDates = [];
        });
        _manualAddressIdController.clear();
        _loadDefaultMedia();
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

  void _delete(String id) {
    // Delete functionality not available in backend yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete functionality not yet implemented')),
    );
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
                child: _inputForm(),
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.spa, color: Colors.green, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wellness Subscriptions List',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'View and manage all wellness subscriptions',
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
                                borderSide: const BorderSide(color: Colors.green, width: 2),
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
                            backgroundColor: Colors.green,
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
                                      Icon(Icons.spa, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No wellness subscriptions found',
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
                                          color: Colors.green.shade50,
                                        ),
                                        child: subscription['media'] != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  subscription['media'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.spa, color: Colors.green),
                                                ),
                                              )
                                            : const Icon(Icons.spa, color: Colors.green),
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
                                            onPressed: () => _delete(subscription['_id'] ?? subscription['id'] ?? ''),
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

  Widget _inputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.spa, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Wellness Subscription',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add a new wellness course or class',
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
        // Toggle between file upload and URL
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Upload File'),
                value: false,
                groupValue: _useMediaUrl,
                onChanged: (value) {
                  setState(() {
                    _useMediaUrl = false;
                    _mediaUrlController.clear();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Image URL'),
                value: true,
                groupValue: _useMediaUrl,
                onChanged: (value) {
                  setState(() {
                    _useMediaUrl = true;
                    _selectedMedia = null;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_useMediaUrl)
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
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tap to select image', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _mediaUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL *',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: const Icon(Icons.link, color: Colors.grey),
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) => setState(() {}), // Refresh to show preview
              ),
              const SizedBox(height: 8),
              if (_mediaUrlController.text.isNotEmpty)
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _mediaUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Invalid image URL', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
            ],
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
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        _categories.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Loading categories...'),
              )
            : DropdownButtonFormField<String>(
                value: _wellnessCategoryId ?? _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: const Icon(Icons.category, color: Colors.grey),
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  helperText: 'Wellness category (locked to wellness)',
                ),
                // Filter to only show wellness categories (exclude fitness)
                items: _categories.where((cat) {
                  final categoryName = (cat['cName'] ?? '').toString().toLowerCase();
                  return categoryName.contains('wellness') && !categoryName.contains('fitness');
                }).map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['_id']?.toString() ?? cat['id']?.toString(),
                    child: Text(cat['cName'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    // Verify it's still a wellness category
                    final selectedCat = _categories.firstWhere(
                      (cat) => (cat['_id']?.toString() ?? cat['id']?.toString()) == value,
                      orElse: () => {},
                    );
                    final categoryName = (selectedCat['cName'] ?? '').toString().toLowerCase();
                    if (!categoryName.contains('wellness')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Only wellness categories are allowed in Wellness Card Manager')),
                      );
                      return;
                    }
                    
                    setState(() {
                      _selectedCategoryId = value;
                      _wellnessCategoryId = value; // Update wellness category ID
                      _selectedSessionTypeId = null;
                    });
                    _masterDataService.getSessionsByCategoryId(value).then((sessions) {
                      if (mounted) {
                        setState(() {
                          _sessions = sessions;
                        });
                      }
                    }).catchError((e) {
                      if (mounted) {
                        print('Error loading sessions: $e');
                      }
                    });
                  }
                },
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
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _trainers.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Loading trainers...'),
              )
            : DropdownButtonFormField<String>(
                value: _selectedTrainerId,
                decoration: InputDecoration(
                  labelText: 'Trainer *',
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _trainers.map((trainer) {
                  return DropdownMenuItem<String>(
                    value: trainer['_id']?.toString() ?? trainer['id']?.toString(),
                    child: Text('${trainer['first_name'] ?? ''} ${trainer['last_name'] ?? ''}'.trim()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTrainerId = value;
                  });
                },
              ),
        const SizedBox(height: 16),
        _sessions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Select a category first to load sessions'),
              )
            : DropdownButtonFormField<String>(
                value: _selectedSessionTypeId,
                decoration: InputDecoration(
                  labelText: 'Session Type *',
                  prefixIcon: const Icon(Icons.fitness_center, color: Colors.grey),
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _sessions.map((session) {
                  return DropdownMenuItem<String>(
                    value: session['_id']?.toString() ?? session['id']?.toString(),
                    child: Text(session['sessionName'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSessionTypeId = value;
                  });
                },
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
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Location/Address *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Row(
              children: [
                Text('Select', style: TextStyle(fontSize: 12)),
                Switch(
                  value: _useManualAddress,
                  onChanged: (value) {
                    setState(() {
                      _useManualAddress = value;
                      if (value) {
                        _selectedAddressId = null;
                      } else {
                        _manualAddressIdController.clear();
                      }
                    });
                  },
                ),
                Text('Manual', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _useManualAddress
            ? TextField(
                controller: _manualAddressIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Location ID *',
                  hintText: 'Enter LocationMaster ObjectId',
                  prefixIcon: const Icon(Icons.edit_location, color: Colors.grey),
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedAddressId = value.trim().isEmpty ? null : value.trim();
                  });
                },
              )
            : _isLoadingLocations
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading locations...'),
                      ],
                    ),
                  )
                : _locations.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No locations found. Tap to retry.',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadLocations,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedAddressId,
                        decoration: InputDecoration(
                          labelText: 'Select Location/Address *',
                          prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
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
                            borderSide: const BorderSide(color: Colors.green, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem<String>(
                            value: location['_id']?.toString() ?? location['id']?.toString(),
                            child: Text(location['streetName'] ?? location['name'] ?? 'Unknown Location'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAddressId = value;
                          });
                        },
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
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
                    borderSide: const BorderSide(color: Colors.green, width: 2),
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
                  const Icon(Icons.calendar_today, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Class Dates',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedDates.length} date${_selectedDates.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.green.shade900,
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
                    backgroundColor: Colors.green,
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
                      backgroundColor: Colors.green.shade50,
                      labelStyle: TextStyle(color: Colors.green.shade900),
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
                activeColor: Colors.green,
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
                activeColor: Colors.green,
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
              _isLoading ? 'Creating...' : 'Create Wellness Subscription',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
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
    _mediaUrlController.dispose();
    _manualAddressIdController.dispose();
    super.dispose();
  }
}
