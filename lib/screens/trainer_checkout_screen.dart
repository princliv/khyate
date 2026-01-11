import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/trainer_service.dart';

class TrainerCheckoutScreen extends StatefulWidget {
  final String orderDetailsId;
  final Map<String, dynamic>? jobData;

  const TrainerCheckoutScreen({
    super.key,
    required this.orderDetailsId,
    this.jobData,
  });

  @override
  State<TrainerCheckoutScreen> createState() => _TrainerCheckoutScreenState();
}

class _TrainerCheckoutScreenState extends State<TrainerCheckoutScreen> {
  final _trainerService = TrainerService();
  final _notesController = TextEditingController();
  
  List<File> _completionImages = [];
  bool _isLoading = false;
  bool _checkoutInitiated = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _completionImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _initiateCheckout() async {
    setState(() => _isLoading = true);
    try {
      await _trainerService.initiateCheckout(
        orderDetailsId: widget.orderDetailsId,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      setState(() {
        _checkoutInitiated = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout initiated. Please complete with images.')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating checkout: ${e.toString()}')),
      );
    }
  }

  Future<void> _completeCheckout() async {
    // Note: Backend actually requires OTP, but API doc shows images
    // For now, we'll use empty array as per API documentation
    // If backend requires OTP, this needs to be updated
    setState(() => _isLoading = true);
    try {
      // Upload images first to get URLs
      final imageUrls = <String>[];
      if (_completionImages.isNotEmpty) {
        // If image upload service is available, use it
        // Otherwise, send empty array (backend may handle images differently)
        for (final file in _completionImages) {
          // For now, we'll need to upload via multipart if backend supports it
          // This is a placeholder - actual implementation depends on backend
          imageUrls.add(file.path); // Temporary - should be actual URLs
        }
      }
      
      await _trainerService.completeCheckout(
        orderDetailsId: widget.orderDetailsId,
        completionTime: DateTime.now().toIso8601String(),
        images: imageUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout completed successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing checkout: ${e.toString()}')),
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
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.jobData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.jobData!['serviceName'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Date: ${widget.jobData!['date'] ?? 'N/A'}'),
                      Text('Time: ${widget.jobData!['time'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_checkoutInitiated) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Initiate Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _initiateCheckout,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Initiate Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text('Add completion images:'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Select Images'),
                      ),
                      const SizedBox(height: 16),
                      if (_completionImages.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _completionImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      _completionImages[index],
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _completionImages.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completeCheckout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Complete Checkout'),
                        ),
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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

