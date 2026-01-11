import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/subservice_service.dart';
import '../../services/master_data_service.dart';

class SubServiceManager extends StatefulWidget {
  @override
  State<SubServiceManager> createState() => _SubServiceManagerState();
}

class _SubServiceManagerState extends State<SubServiceManager> {
  final _subServiceService = SubServiceService();
  final _masterDataService = MasterDataService();
  
  final _nameController = TextEditingController();
  final _groomingDetailsController = TextEditingController();
  final _searchController = TextEditingController();
  
  File? _selectedImage;
  String? _selectedServiceTypeId;
  List<dynamic> _serviceTypes = [];
  List<dynamic> _subServices = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
    _loadSubServices();
  }

  Future<void> _loadServiceTypes() async {
    try {
      final services = await _masterDataService.getAllCustomerServices();
      if (mounted) {
        setState(() {
          _serviceTypes = services;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading service types: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadSubServices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _subServiceService.getAllSubServices(
        page: _page,
        limit: _limit,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (mounted) {
        setState(() {
          _subServices = result?['subservices'] ?? result?['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sub services: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> subService) async {
    final editNameController = TextEditingController(text: subService['name'] ?? '');
    final editGroomingController = TextEditingController(
      text: subService['groomingDetails'] != null
          ? (subService['groomingDetails'] is String
              ? subService['groomingDetails']
              : jsonEncode(subService['groomingDetails']))
          : '[]',
    );
    File? editImage;
    String? editImageUrl = subService['image'] ?? subService['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Sub Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        editImage = File(pickedFile.path);
                        editImageUrl = null;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: editImage != null
                        ? Image.file(editImage!, fit: BoxFit.cover)
                        : editImageUrl != null
                            ? Image.network(editImageUrl!, fit: BoxFit.cover)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48),
                                  SizedBox(height: 8),
                                  Text('Tap to select image'),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editGroomingController,
                  decoration: const InputDecoration(
                    labelText: 'Grooming Details (JSON)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                if (editNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                try {
                  await _subServiceService.updateSubService(
                    subServiceId: subService['_id'] ?? subService['id'] ?? '',
                    image: editImage,
                    name: editNameController.text,
                    groomingDetails: editGroomingController.text.isEmpty
                        ? null
                        : editGroomingController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sub service updated successfully')),
                    );
                    _loadSubServices();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSubService() async {
    if (_nameController.text.isEmpty || _selectedServiceTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _subServiceService.createSubService(
        image: _selectedImage,
        name: _nameController.text,
        serviceTypeId: _selectedServiceTypeId!,
        groomingDetails: _groomingDetailsController.text.isEmpty
            ? '[]'
            : _groomingDetailsController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sub service created successfully')),
        );
        
        _nameController.clear();
        _groomingDetailsController.clear();
        setState(() {
          _selectedImage = null;
          _selectedServiceTypeId = null;
        });
        _loadSubServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating sub service: ${e.toString()}')),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Sub Service',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48),
                                SizedBox(height: 8),
                                Text('Tap to select image'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _serviceTypes.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Loading service types...'),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedServiceTypeId != null &&
                                  _serviceTypes.any((s) =>
                                      (s['_id']?.toString() ?? s['id']?.toString()) == _selectedServiceTypeId)
                              ? _selectedServiceTypeId
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Service Type *',
                            border: OutlineInputBorder(),
                          ),
                          items: _serviceTypes.map((service) {
                            final serviceId = service['_id']?.toString() ?? service['id']?.toString();
                            if (serviceId == null) return null;
                            return DropdownMenuItem<String>(
                              value: serviceId,
                              child: Text(service['name'] ?? 'Unknown'),
                            );
                          }).whereType<DropdownMenuItem<String>>().toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedServiceTypeId = value;
                              });
                            }
                          },
                        ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _groomingDetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Grooming Details (JSON)',
                      border: OutlineInputBorder(),
                      hintText: '[{"weightType":"small","price":100}]',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createSubService,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Sub Service'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Search and List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loadSubServices,
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _subServices.isEmpty
                          ? const Center(child: Text('No sub services found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _subServices.length,
                              itemBuilder: (context, index) {
                                final subService = _subServices[index];
                                return ListTile(
                                  title: Text(subService['name'] ?? 'Unknown'),
                                  subtitle: Text(
                                    'Service Type: ${subService['serviceTypeId'] ?? 'N/A'}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditDialog(subService),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          // TODO: Implement delete
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
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
    _groomingDetailsController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

