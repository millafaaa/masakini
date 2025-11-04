import 'package:flutter/material.dart';
import 'package:masakini/models/recipe_model.dart';
import 'package:masakini/services/firestore_service.dart';
import 'package:masakini/widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _selectedIngredients = [];
  bool _isSearchingByIngredients = false;
  String _currentQuery = '';
  String? _selectedCategory;

  final List<String> _commonIngredients = [
    'ayam', 'daging sapi', 'ikan', 'telur', 'bayam', 'wortel', 'bawang merah', 'bawang putih',
    'garam', 'gula', 'merica', 'kecap', 'santan', 'beras', 'mie', 'tempe', 'tahu', 'kentang',
    'tomat', 'cabai', 'jahe', 'kunyit', 'daun bawang', 'kol', 'jagung', 'udang', 'cumi',
  ];
  
  final List<String> _categories = [
    'Semua',
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
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearIngredients() {
    setState(() => _selectedIngredients.clear());
  }

  void _toggleSearchMode(bool isIngredients) {
    setState(() {
      _isSearchingByIngredients = isIngredients;
      if (isIngredients) {
        _searchController.clear();
        _currentQuery = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _currentQuery = query.toLowerCase());
  }

  void _onIngredientToggled(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Resep'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Fitur segera hadir')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari resep berdasarkan judul',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _isSearchingByIngredients ? null : _onSearchChanged,
            ),
          ),
          // Toggle search mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleSearchMode(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isSearchingByIngredients ? Colors.orange : null,
                    ),
                    child: const Text('Cari Judul'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleSearchMode(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isSearchingByIngredients ? Colors.orange : null,
                    ),
                    child: const Text('Cari Bahan'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category || 
                                 (category == 'Semua' && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'Semua' ? null : category;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Ingredients mode
          if (_isSearchingByIngredients) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pilih Bahan',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed:
                        _selectedIngredients.isEmpty ? null : _clearIngredients,
                    child: const Text('Hapus Semua'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _commonIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _commonIngredients[index];
                  return FilterChip(
                    label: Text(ingredient),
                    selected: _selectedIngredients.contains(ingredient),
                    onSelected: (_) => _onIngredientToggled(ingredient),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Results
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Recipe>>(
      stream: _firestoreService.getAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada resep'));
        }

        // Apply filters
        var recipes = snapshot.data!;

        // Filter by category
        if (_selectedCategory != null) {
          recipes = recipes.where((recipe) => 
            recipe.category.toLowerCase() == _selectedCategory!.toLowerCase()
          ).toList();
        }

        // Filter by search query
        if (!_isSearchingByIngredients && _currentQuery.isNotEmpty) {
          recipes = recipes.where((recipe) =>
            recipe.title.toLowerCase().contains(_currentQuery.toLowerCase()) ||
            recipe.description.toLowerCase().contains(_currentQuery.toLowerCase())
          ).toList();
        }

        // Filter by ingredients
        if (_isSearchingByIngredients && _selectedIngredients.isNotEmpty) {
          recipes = recipes.where((recipe) {
            return _selectedIngredients.every((selectedIngredient) =>
              recipe.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(selectedIngredient.toLowerCase())
              )
            );
          }).toList();
        }

        if (recipes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Tidak ada resep yang cocok 😔'),
                Text('Coba pencarian lain'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return RecipeCard(
              recipe: recipe,
              onTap: () => Navigator.pushNamed(context, '/detail', arguments: recipe),
            );
          },
        );
      },
    );
  }
}
