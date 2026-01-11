import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';

class ArticleManager extends StatefulWidget {
  @override
  State<ArticleManager> createState() => _ArticleManagerState();
}

class _ArticleManagerState extends State<ArticleManager> {
  final _adminService = AdminService();
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  
  File? _selectedImage;
  bool _isPublished = true;
  List<dynamic> _articles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    // Get current user name as author
    try {
      final userProfile = await ApiService.get(
        '${ApiService.baseUrl}/user/get-user-profile',
        requireAuth: true,
      );
      if (userProfile['success'] == true) {
        final data = userProfile['data'];
        final userData = data['data'] ?? data;
        _authorController.text = userData['first_name'] ?? 'Admin';
      }
    } catch (e) {
      _authorController.text = 'Admin';
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

  Future<void> _showEditDialog(Map<String, dynamic> article) async {
    final editTitleController = TextEditingController(text: article['title'] ?? '');
    final editContentController = TextEditingController(text: article['content'] ?? '');
    File? editImage;
    String? editImageUrl = article['image'] ?? article['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Article'),
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
                  controller: editTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editContentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
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
                  await _adminService.updateArticle(
                    articleId: article['_id'] ?? article['id'] ?? '',
                    image: editImage,
                    title: editTitleController.text.isEmpty
                        ? null
                        : editTitleController.text,
                    content: editContentController.text.isEmpty
                        ? null
                        : editContentController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article updated successfully')),
                    );
                    // TODO: Reload articles list
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

  Future<void> _createArticle() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _adminService.createArticle(
        image: _selectedImage,
        title: _titleController.text,
        content: _contentController.text,
        author: _authorController.text,
        isPublished: _isPublished,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article created successfully')),
      );
      
      _titleController.clear();
      _contentController.clear();
      _selectedImage = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating article: ${e.toString()}')),
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
                    'Create Article',
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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Is Published'),
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() {
                        _isPublished = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createArticle,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Article'),
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
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}

