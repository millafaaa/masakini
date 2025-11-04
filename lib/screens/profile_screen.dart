import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_screen.dart';
import 'settings_screen.dart';
import 'detail_recipe_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _userProfile;
  File? _newProfilePhoto;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    if (userId != null) {
      final profile = await _firestoreService.getUserProfile(userId);
      setState(() => _userProfile = profile);
    }
  }

  Future<void> _pickProfilePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _newProfilePhoto = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile(String? newName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    String photoUrl = _userProfile?['photoUrl'] ?? '';
    if (_newProfilePhoto != null) {
      photoUrl = await _storageService.uploadProfilePhoto(user.uid, _newProfilePhoto!);
    }

    try {
      await authProvider.updateDisplayName(newName ?? user.displayName ?? '');
      await _firestoreService.updateUserProfile(
        user.uid,
        displayName: newName,
        photoUrl: photoUrl,
      );
      _loadUserProfile();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showEditDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentName = _userProfile?['displayName'] ??
        authProvider.user?.displayName ??
        '';
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickProfilePhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _newProfilePhoto != null
                    ? FileImage(_newProfilePhoto!) as ImageProvider
                    : ((_userProfile?['photoUrl'] as String?)?.isNotEmpty == true
                        ? NetworkImage(_userProfile!['photoUrl'] as String) as ImageProvider
                        : null),
                child: (_newProfilePhoto == null &&
                        ((_userProfile?['photoUrl'] as String?)?.isEmpty ?? true))
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.user?.email ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => _updateProfile(
              nameController.text.trim().isEmpty
                  ? null
                  : nameController.text.trim(),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecipe(String recipeId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.deleteRecipe(recipeId);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context)
                    .showSnackBar(const SnackBar(content: Text('Resep berhasil dihapus')));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _editRecipe(Recipe recipe) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Silakan login untuk melihat profil.')),
      );
    }

    final displayName =
        _userProfile?['displayName'] ?? user.displayName ?? user.email ?? 'Pengguna';
    final photoUrl = _userProfile?['photoUrl'] ?? user.photoURL ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showEditDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(displayName,
                style: Theme.of(context).textTheme.headlineSmall),
            Text(user.email ?? '',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await authProvider.signOut();
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // My Recipes
            _buildSection(
              title: 'Resep Saya',
              icon: Icons.restaurant_menu,
              child: StreamBuilder<List<Recipe>>(
                stream: _firestoreService.getUserRecipes(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final recipes = snapshot.data ?? [];
                  if (recipes.isEmpty) {
                    return const Center(child: Text('Belum ada resep'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.restaurant),
                            ),
                          ),
                          title: Text(recipe.title),
                          subtitle: Text(recipe.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () => _editRecipe(recipe),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRecipe(recipe.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Favorites
            _buildSection(
              title: 'Favorit',
              icon: Icons.favorite,
              child: StreamBuilder<List<Recipe>>(
                stream: _firestoreService.getUserFavorites(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final recipes = snapshot.data ?? [];
                  if (recipes.isEmpty) {
                    return const Center(child: Text('Belum ada favorit'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailRecipeScreen(recipe: recipe),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
