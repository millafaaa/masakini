import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masakini/models/recipe_model.dart';
import 'package:masakini/services/database_service.dart';
import 'package:masakini/providers/auth_provider.dart';
import 'package:masakini/screens/detail_recipe_screen.dart';
import 'package:masakini/screens/admin_panel_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final List<String> _selectedIngredients = [];

  late TabController _tabController;

  String _currentQuery = '';
  String? _selectedCategory;
  String? _selectedCuisineType;
  String? _selectedDifficulty;

  final List<String> _commonIngredients = [
    'ayam',
    'daging sapi',
    'daging kambing',
    'ikan',
    'udang',
    'cumi',
    'telur',
    'bayam',
    'kangkung',
    'wortel',
    'kol',
    'brokoli',
    'kentang',
    'tomat',
    'bawang merah',
    'bawang putih',
    'bawang bombay',
    'cabai',
    'jahe',
    'kunyit',
    'garam',
    'gula',
    'merica',
    'kecap manis',
    'kecap asin',
    'saus tiram',
    'santan',
    'kelapa',
    'beras',
    'mie',
    'tempe',
    'tahu',
    'keju',
    'susu',
    'tepung',
    'roti',
    'pasta',
    'nasi',
    'daun bawang',
    'seledri',
    'jagung',
  ];

  final List<String> _categories = [
    'Semua',
    'Nasi',
    'Daging',
    'Ayam',
    'Ikan',
    'Sup',
    'Sayur',
    'Mi',
    'Snack',
    'Dessert',
  ];

  final List<String> _cuisineTypes = [
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
  ];

  final List<String> _difficulties = [
    'Semua',
    'easy',
    'medium',
    'hard',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedIngredients.clear();
      _searchController.clear();
      _currentQuery = '';
      _selectedCategory = null;
      _selectedCuisineType = null;
      _selectedDifficulty = null;
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
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    final isAdmin = userProfile?['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Resep'),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Cari'),
            Tab(icon: Icon(Icons.restaurant), text: 'Bahan'),
            Tab(icon: Icon(Icons.filter_alt), text: 'Filter'),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Filters',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildIngredientsTab(),
                _buildFiltersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Search by Title
  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari resep berdasarkan judul atau deskripsi',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _currentQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 12),
              // Quick cuisine type filter
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cuisineTypes.length,
                  itemBuilder: (context, index) {
                    final type = _cuisineTypes[index];
                    final isSelected = _selectedCuisineType == type ||
                        (type == 'Semua' && _selectedCuisineType == null);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCuisineType =
                                type == 'Semua' ? null : type;
                          });
                        },
                        selectedColor: Colors.orange.withValues(alpha: 0.3),
                        checkmarkColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSearchResults()),
      ],
    );
  }

  // Tab 2: Search by Ingredients
  Widget _buildIngredientsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Bahan-Bahan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_selectedIngredients.isNotEmpty)
                    Chip(
                      label: Text('${_selectedIngredients.length} dipilih'),
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedIngredients.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedIngredients.map((ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _onIngredientToggled(ingredient),
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _commonIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = _commonIngredients[index];
              final isSelected = _selectedIngredients.contains(ingredient);
              return FilterChip(
                label: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _onIngredientToggled(ingredient),
                selectedColor: Colors.orange,
                checkmarkColor: Colors.white,
              );
            },
          ),
        ),
        if (_selectedIngredients.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.search),
                  label: Text('Cari ${_selectedIngredients.length} Bahan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Tab 3: Advanced Filters
  Widget _buildFiltersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Filter Lanjutan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Category Filter
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category ||
                (category == 'Semua' && _selectedCategory == null);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category == 'Semua' ? null : category;
                });
              },
              selectedColor: Colors.orange.withValues(alpha: 0.3),
              checkmarkColor: Colors.orange,
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Cuisine Type Filter
        Text(
          'Tipe Masakan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _cuisineTypes.map((type) {
            final isSelected = _selectedCuisineType == type ||
                (type == 'Semua' && _selectedCuisineType == null);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCuisineType = type == 'Semua' ? null : type;
                });
              },
              selectedColor: Colors.orange.withValues(alpha: 0.3),
              checkmarkColor: Colors.orange,
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Difficulty Filter
        Text(
          'Tingkat Kesulitan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _difficulties.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty ||
                (difficulty == 'Semua' && _selectedDifficulty == null);
            return FilterChip(
              label: Text(difficulty == 'Semua'
                  ? difficulty
                  : difficulty.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedDifficulty =
                      difficulty == 'Semua' ? null : difficulty;
                });
              },
              selectedColor: Colors.orange.withValues(alpha: 0.3),
              checkmarkColor: Colors.orange,
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Apply Filters Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Icons.done),
            label: const Text('Terapkan Filter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Recipe>>(
      stream: _databaseService.getAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum ada resep', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        // Apply all filters
        var recipes = snapshot.data!;

        // Filter by category
        if (_selectedCategory != null) {
          recipes = recipes
              .where((recipe) =>
                  recipe.category.toLowerCase() ==
                  _selectedCategory!.toLowerCase())
              .toList();
        }

        // Filter by cuisine type
        if (_selectedCuisineType != null) {
          recipes = recipes
              .where((recipe) =>
                  recipe.cuisineType.toLowerCase() ==
                  _selectedCuisineType!.toLowerCase())
              .toList();
        }

        // Filter by difficulty
        if (_selectedDifficulty != null) {
          recipes = recipes
              .where((recipe) =>
                  recipe.difficulty.toLowerCase() ==
                  _selectedDifficulty!.toLowerCase())
              .toList();
        }

        // Filter by search query (title or description)
        if (_currentQuery.isNotEmpty) {
          recipes = recipes
              .where((recipe) =>
                  recipe.title.toLowerCase().contains(_currentQuery) ||
                  recipe.description.toLowerCase().contains(_currentQuery) ||
                  recipe.category.toLowerCase().contains(_currentQuery) ||
                  recipe.cuisineType.toLowerCase().contains(_currentQuery))
              .toList();
        }

        // Filter by ingredients
        if (_selectedIngredients.isNotEmpty) {
          recipes = recipes.where((recipe) {
            return _selectedIngredients.every((selectedIngredient) =>
                recipe.ingredients.any((ingredient) => ingredient
                    .toLowerCase()
                    .contains(selectedIngredient.toLowerCase())));
          }).toList();
        }

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Tidak ada resep yang cocok 😔',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                const Text('Coba pencarian lain',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filter'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return _buildRecipeCard(recipe);
          },
        );
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailRecipeScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Image.network(
                  recipe.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 64, color: Colors.grey),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          recipe.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.cuisineType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(recipe.category),
                        backgroundColor: Colors.pink.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(fontSize: 12),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.cookingTime} min',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.local_fire_department,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty.toUpperCase(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
