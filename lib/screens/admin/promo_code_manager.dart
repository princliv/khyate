import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_service.dart';

class PromoCodeManager extends StatefulWidget {
  @override
  State<PromoCodeManager> createState() => _PromoCodeManagerState();
}

class _PromoCodeManagerState extends State<PromoCodeManager> {
  final _adminService = AdminService();
  
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _maxDiscountAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _termsAndConditionsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _applyOfferAfterOrdersController = TextEditingController();
  final _searchController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  File? _selectedImage;
  bool _useImageUrl = false;
  String? _selectedDiscountType = 'percentage';
  bool _isActive = true;
  List<dynamic> _promoCodes = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadPromoCodes();
  }

  Future<void> _loadPromoCodes() async {
    setState(() => _isLoading = true);
    try {
      // API spec says POST with no body required
      final result = await _adminService.getAllPromoCodes();
      setState(() {
        _promoCodes = result?['promoCodes'] ?? result?['data'] ?? (result is List ? result : []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading promo codes: ${e.toString()}')),
      );
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

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> promo) async {
    final editDiscountValueController = TextEditingController(
      text: promo['discountValue']?.toString() ?? '',
    );
    final editValidToController = TextEditingController(
      text: promo['validTo'] ?? '',
    );
    File? editImage;
    String? editImageUrl = promo['image'] ?? promo['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Promo Code'),
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
                  controller: editDiscountValueController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Value',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editValidToController,
                  decoration: const InputDecoration(
                    labelText: 'Valid To',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _pickDate(editValidToController),
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
                try {
                  await _adminService.updatePromoCode(
                    promoCodeId: promo['_id'] ?? promo['id'] ?? '',
                    image: editImage,
                    discountValue: editDiscountValueController.text.isEmpty
                        ? null
                        : double.tryParse(editDiscountValueController.text),
                    endDate: editValidToController.text.isEmpty
                        ? null
                        : editValidToController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Promo code updated successfully')),
                    );
                    _loadPromoCodes();
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

  Future<void> _createPromoCode() async {
    if (_codeController.text.isEmpty ||
        _discountValueController.text.isEmpty ||
        _maxUsesController.text.isEmpty ||
        _termsAndConditionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (Code, Discount Value, Max Uses, Terms & Conditions)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _adminService.createPromoCode(
        image: _useImageUrl ? null : _selectedImage,
        imageUrl: _useImageUrl ? _imageUrlController.text.trim() : null,
        code: _codeController.text,
        discountType: _selectedDiscountType!,
        discountValue: double.parse(_discountValueController.text),
        maxUses: int.parse(_maxUsesController.text),
        termsAndConditions: _termsAndConditionsController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        isActive: _isActive,
        isValidationDate: _startDateController.text.isNotEmpty || _endDateController.text.isNotEmpty,
        startDate: _startDateController.text.isEmpty ? null : _startDateController.text,
        endDate: _endDateController.text.isEmpty ? null : _endDateController.text,
        applyOfferAfterOrders: _applyOfferAfterOrdersController.text.isEmpty 
            ? null 
            : int.tryParse(_applyOfferAfterOrdersController.text),
        minOrderAmount: _minOrderAmountController.text.isEmpty 
            ? null 
            : double.tryParse(_minOrderAmountController.text),
        maxDiscountAmount: _maxDiscountAmountController.text.isEmpty 
            ? null 
            : double.tryParse(_maxDiscountAmountController.text),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promo code created successfully')),
      );
      
      _codeController.clear();
      _discountValueController.clear();
      _minOrderAmountController.clear();
      _maxDiscountAmountController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _maxUsesController.clear();
      _termsAndConditionsController.clear();
      _descriptionController.clear();
      _applyOfferAfterOrdersController.clear();
      _imageUrlController.clear();
      setState(() {
        _selectedImage = null;
        _useImageUrl = false;
      });
      _loadPromoCodes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating promo code: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                    'Create Promo Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Toggle between file upload and URL
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Upload File'),
                          value: false,
                          groupValue: _useImageUrl,
                          onChanged: (value) {
                            setState(() {
                              _useImageUrl = false;
                              _imageUrlController.clear();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Image URL'),
                          value: true,
                          groupValue: _useImageUrl,
                          onChanged: (value) {
                            setState(() {
                              _useImageUrl = true;
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_useImageUrl)
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
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL *',
                            hintText: 'https://example.com/image.jpg',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() {}), // Refresh to show preview
                        ),
                        const SizedBox(height: 8),
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrlController.text,
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDiscountType,
                    decoration: const InputDecoration(
                      labelText: 'Discount Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                      DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDiscountType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _discountValueController,
                    decoration: const InputDecoration(
                      labelText: 'Discount Value *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _minOrderAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Min Order Amount *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxDiscountAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Max Discount Amount *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: const InputDecoration(
                            labelText: 'Valid From *',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _pickDate(_startDateController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: const InputDecoration(
                            labelText: 'Valid To *',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _pickDate(_endDateController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxUsesController,
                    decoration: const InputDecoration(
                      labelText: 'Max Uses *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _termsAndConditionsController,
                    decoration: const InputDecoration(
                      labelText: 'Terms & Conditions *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: const InputDecoration(
                            labelText: 'Start Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _pickDate(_startDateController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: const InputDecoration(
                            labelText: 'End Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _pickDate(_endDateController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _applyOfferAfterOrdersController,
                    decoration: const InputDecoration(
                      labelText: 'Apply Offer After Orders (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Is Active'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createPromoCode,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Promo Code'),
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
                        onPressed: _loadPromoCodes,
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _promoCodes.isEmpty
                          ? const Center(child: Text('No promo codes found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _promoCodes.length,
                              itemBuilder: (context, index) {
                                final promo = _promoCodes[index];
                                return ListTile(
                                  title: Text(promo['code'] ?? 'Unknown'),
                                  subtitle: Text(
                                    'Discount: ${promo['discountValue'] ?? 'N/A'} ${promo['discountType'] ?? ''}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditDialog(promo),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Promo Code'),
                                              content: const Text('Are you sure you want to delete this promo code?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            try {
                                              await _adminService.deletePromoCode(
                                                promoCodeId: promo['_id'] ?? promo['id'] ?? '',
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Promo code deleted successfully')),
                                                );
                                                _loadPromoCodes();
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error deleting promo code: ${e.toString()}')),
                                                );
                                              }
                                            }
                                          }
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
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderAmountController.dispose();
    _maxDiscountAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _maxUsesController.dispose();
    _termsAndConditionsController.dispose();
    _descriptionController.dispose();
    _applyOfferAfterOrdersController.dispose();
    _searchController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}

