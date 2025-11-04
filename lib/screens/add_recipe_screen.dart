import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import 'package:masakini/providers/auth_provider.dart';
import 'package:masakini/services/firestore_service.dart';
import 'package:masakini/services/storage_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();

  final List<String> _ingredients = [];
  final List<String> _steps = [];
  File? _image;
  bool _isSubmitting = false;
  String _selectedDifficulty = 'easy';
  
  // Predefined categories
  final List<String> _categories = [
    'Indonesian',
    'Western',
    'Chinese',
    'Japanese',
    'Korean',
    'Thai',
    'Indian',
    'Italian',
    'Mexican',
    'Dessert',
    'Minuman',
    'Snack',
    'Lainnya',
  ];
  String? _selectedCategory;

  final _picker = ImagePicker();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kurangi quality untuk upload lebih cepat
      maxWidth: 1024, // Resize ke max 1024px
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(text);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    final text = _stepController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _steps.add(text);
        _stepController.clear();
      });
    }
  }

  Future<void> _submitRecipe() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard

    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk menambah resep.')),
      );
      return;
    }

    if (_ingredients.isEmpty || _steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal satu bahan dan satu langkah.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menyimpan resep...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      String imageUrl = '';
      if (_image != null) {
        imageUrl = await _storageService.uploadRecipeImage(_image!, user.uid);
      } else {
        // Default image jika tidak ada foto
        imageUrl = 'https://via.placeholder.com/400x300?text=No+Image';
      }

      // Get user profile for userName and userAvatar
      final userProfile = await _firestoreService.getUserProfile(user.uid);
      final userName = userProfile?['displayName'] ?? user.displayName ?? user.email ?? 'Anonymous';
      final userAvatar = userProfile?['photoUrl'] ?? user.photoURL ?? '';

      final recipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: userName,
        userAvatar: userAvatar,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? 'Resep ${_titleController.text.trim()}' 
            : _descriptionController.text.trim(),
        image: imageUrl,
        category: _selectedCategory ?? _categoryController.text.trim(),
        cookingTime: int.tryParse(_cookingTimeController.text.trim()) ?? 30,
        servings: int.tryParse(_servingsController.text.trim()) ?? 2,
        difficulty: _selectedDifficulty,
        ingredients: _ingredients,
        steps: _steps,
        ratings: [],
        reviews: [],
        favorites: [],
        createdAt: Timestamp.now(),
      );

      await _firestoreService.addRecipe(recipe);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil ditambahkan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _ingredientController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Resep'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!,
                            height: 220,
                            fit: BoxFit.cover,
                            width: double.infinity),
                      )
                    : Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Center(
                          child: Icon(Icons.camera_alt,
                              color: Colors.orange, size: 48),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Judul Resep
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Resep *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Judul terlalu pendek';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Ceritakan tentang resep ini...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Kategori Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) =>
                    value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),

              // Row: Cooking Time & Servings
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cookingTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Waktu (menit)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Porsi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Difficulty Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Tingkat Kesulitan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Mudah')),
                  DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                  DropdownMenuItem(value: 'hard', child: Text('Sulit')),
                ],
                onChanged: (value) {
                  setState(() => _selectedDifficulty = value!);
                },
              ),
              const SizedBox(height: 16),

              // Bahan
              _buildInputSection(
                title: 'Bahan',
                controller: _ingredientController,
                onAdd: _addIngredient,
                items: _ingredients,
              ),
              const SizedBox(height: 16),

              // Langkah
              _buildInputSection(
                title: 'Langkah Memasak',
                controller: _stepController,
                onAdd: _addStep,
                items: _steps,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitRecipe,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isSubmitting ? 'Menyimpan...' : 'Simpan Resep',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 14 : 18, horizontal: 16),
                  textStyle: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.orange)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan $title...',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: onAdd,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => ListTile(
                dense: true,
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => setState(() => items.remove(item)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
