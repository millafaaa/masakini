import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masakini/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    final isAdmin = userProfile?['role'] == 'admin';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('You do not have admin privileges'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Recipes'),
            Tab(icon: Icon(Icons.history), text: 'Activity Log'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildUsersTab(),
          _buildRecipesTab(),
          _buildActivityLogTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // Tab 1: Dashboard
  Widget _buildDashboardTab() {
    return FutureBuilder<Map<String, int>>(
      future: _getStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? {};
        final totalUsers = stats['totalUsers'] ?? 0;
        final totalRecipes = stats['totalRecipes'] ?? 0;
        final totalRatings = stats['totalRatings'] ?? 0;
        final totalFavorites = stats['totalFavorites'] ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Total Recipes',
                  totalRecipes.toString(),
                  Icons.restaurant_menu,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Ratings',
                  totalRatings.toString(),
                  Icons.star,
                  Colors.amber,
                ),
                _buildStatCard(
                  'Total Favorites',
                  totalFavorites.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('Add New User'),
              subtitle: const Text('Create a new user account'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAddUserDialog(),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clean Old Logs'),
              subtitle: const Text('Remove logs older than 30 days'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _cleanOldLogs(),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.backup, color: Colors.green),
              title: const Text('Backup Database'),
              subtitle: const Text('Export all data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _backupDatabase(),
            ),
          ],
        );
      },
    );
  }

  // Tab 2: Users Management
  Widget _buildUsersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No users found'),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total Users: ${users.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isAdmin = user['role'] == 'admin';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isAdmin ? Colors.deepPurple : Colors.blue,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        user['display_name'] ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email'] ?? 'No email'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  isAdmin ? 'Admin' : 'User',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: isAdmin
                                    ? Colors.deepPurple.withValues(alpha: 0.2)
                                    : Colors.blue.withValues(alpha: 0.2),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle_role',
                            child: Row(
                              children: [
                                const Icon(Icons.swap_horiz, size: 20),
                                const SizedBox(width: 8),
                                Text(isAdmin ? 'Make User' : 'Make Admin'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditUserDialog(user);
                              break;
                            case 'toggle_role':
                              _toggleUserRole(user);
                              break;
                            case 'delete':
                              _deleteUser(user);
                              break;
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Tab 3: Manage Recipes
  Widget _buildRecipesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No recipes found'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Recipes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Total: ${recipes.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recipe List
            ...recipes.map((recipe) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recipe['image'] ??
                            'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=800&q=80',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant_menu),
                        ),
                      ),
                    ),
                    title: Text(
                      recipe['title'] ?? 'Untitled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${recipe['category'] ?? 'N/A'} | Cuisine: ${recipe['cuisine_type'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'By: ${recipe['user_name'] ?? 'Unknown'}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editRecipe(recipe);
                        } else if (value == 'delete') {
                          _deleteRecipe(recipe);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  // Tab 4: Activity Log
  Widget _buildActivityLogTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getActivityLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No activity logs yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: _getActivityIcon(log['action']),
                title: Text(log['action'] ?? 'Unknown action'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['description'] ?? 'No description'),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(log['created_at']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Tab 5: Settings
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'App Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        // Theme Settings
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: const Text('Customize app appearance'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showThemeSettings(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Primary Color'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                onTap: () => _changeThemeColor(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Coming Soon Features
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Coming Soon Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              _buildComingSoonItem(
                  '📊 Advanced Analytics', 'Detailed usage statistics'),
              _buildComingSoonItem(
                  '🔔 Push Notifications', 'Notify users about new recipes'),
              _buildComingSoonItem(
                  '💬 Comments System', 'Users can comment on recipes'),
              _buildComingSoonItem(
                  '🏆 Achievement Badges', 'Reward active users'),
              _buildComingSoonItem(
                  '📱 Mobile App', 'Native iOS & Android apps'),
              _buildComingSoonItem(
                  '🤖 AI Recipe Generator', 'Generate recipes with AI'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // About
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Masakini v1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAboutDialog(),
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonItem(String title, String description) {
    return ListTile(
      leading: const Icon(Icons.schedule, color: Colors.orange),
      title: Text(title),
      subtitle: Text(description),
      trailing: Chip(
        label: const Text('Soon', style: TextStyle(fontSize: 10)),
        backgroundColor: Colors.orange.withValues(alpha: 0.2),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Icon _getActivityIcon(String? action) {
    switch (action?.toLowerCase()) {
      case 'login':
        return const Icon(Icons.login, color: Colors.green);
      case 'logout':
        return const Icon(Icons.logout, color: Colors.orange);
      case 'create_recipe':
        return const Icon(Icons.add_circle, color: Colors.blue);
      case 'update_recipe':
        return const Icon(Icons.edit, color: Colors.indigo);
      case 'delete_recipe':
        return const Icon(Icons.delete, color: Colors.red);
      case 'add_rating':
        return const Icon(Icons.star, color: Colors.amber);
      case 'add_favorite':
        return const Icon(Icons.favorite, color: Colors.pink);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    try {
      final dt = timestamp is String
          ? DateTime.parse(timestamp)
          : timestamp as DateTime;
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Data Fetching Methods
  Future<Map<String, int>> _getStatistics() async {
    try {
      final usersCount = await _supabase.from('users').select();
      final recipesCount = await _supabase.from('recipes').select();
      final ratingsCount = await _supabase.from('ratings').select();
      final favoritesCount = await _supabase.from('favorites').select();

      return {
        'totalUsers': usersCount.length,
        'totalRecipes': recipesCount.length,
        'totalRatings': ratingsCount.length,
        'totalFavorites': favoritesCount.length,
      };
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getActivityLogs() async {
    try {
      // This will need the activity_logs table to be created first
      final response = await _supabase
          .from('activity_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting activity logs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getAllRecipes() async {
    try {
      final response = await _supabase.from('recipes').select('''
            *,
            users!inner(display_name)
          ''').order('created_at', ascending: false);

      // Flatten the user data
      return List<Map<String, dynamic>>.from(response.map((recipe) {
        final Map<String, dynamic> flatRecipe = Map.from(recipe);
        if (recipe['users'] != null) {
          flatRecipe['user_name'] = recipe['users']['display_name'];
        }
        flatRecipe.remove('users');
        return flatRecipe;
      }));
    } catch (e) {
      debugPrint('Error getting recipes: $e');
      return [];
    }
  }

  // Action Methods
  void _showAddUserDialog() {
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add User feature coming soon')),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    // TODO: Implement edit user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user: ${user['email']}')),
    );
  }

  void _toggleUserRole(Map<String, dynamic> user) async {
    final newRole = user['role'] == 'admin' ? 'user' : 'admin';
    try {
      await _supabase
          .from('users')
          .update({'role': newRole}).eq('id', user['id']);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role changed to $newRole')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _editRecipe(Map<String, dynamic> recipe) {
    final titleController = TextEditingController(text: recipe['title']);
    final descriptionController =
        TextEditingController(text: recipe['description']);
    final categoryController = TextEditingController(text: recipe['category']);
    final cuisineController =
        TextEditingController(text: recipe['cuisine_type']);
    final difficultyController =
        TextEditingController(text: recipe['difficulty']);
    final cookingTimeController =
        TextEditingController(text: recipe['cooking_time']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cuisineController,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: difficultyController,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cookingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Cooking Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                // Close dialog first
                navigator.pop();

                await _supabase.from('recipes').update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'cuisine_type': cuisineController.text,
                  'difficulty': difficultyController.text,
                  'cooking_time': int.tryParse(cookingTimeController.text),
                  'updated_at': DateTime.now().toIso8601String(),
                }).eq('id', recipe['id']);

                if (mounted) {
                  setState(() {});
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                        content: Text('Recipe updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
            'Are you sure you want to delete "${recipe['title']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                // Close dialog first
                navigator.pop();

                await _supabase.from('recipes').delete().eq('id', recipe['id']);

                if (mounted) {
                  setState(() {});
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                        content: Text('Recipe deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['email']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement user deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Delete user feature coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cleanOldLogs() {
    // TODO: Implement clean old logs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clean old logs feature coming soon')),
    );
  }

  void _backupDatabase() {
    // TODO: Implement database backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database backup feature coming soon')),
    );
  }

  void _showThemeSettings() {
    // TODO: Implement theme settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme settings feature coming soon')),
    );
  }

  void _changeThemeColor() {
    // TODO: Implement color picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Color picker coming soon')),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Masakini',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.restaurant_menu, size: 48),
      children: [
        const Text(
            'A modern recipe sharing platform built with Flutter and Supabase.'),
        const SizedBox(height: 16),
        const Text('© 2025 Masakini. All rights reserved.'),
      ],
    );
  }
}
