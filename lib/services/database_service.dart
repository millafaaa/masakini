import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ✅ Tambah resep baru ke Supabase
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _supabase.from('recipes').insert(recipe.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// 🗑️ Hapus resep berdasarkan ID
  Future<void> deleteRecipe(String id) async {
    try {
      await _supabase.from('recipes').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  /// ⭐ Tambahkan rating dan review baru
  Future<void> addRating(
    String recipeId,
    double rating,
    String review,
    String userId,
  ) async {
    try {
      await _supabase.from('ratings').upsert({
        'recipe_id': recipeId,
        'user_id': userId,
        'rating': rating,
        'review': review,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 💗 Toggle favorit (tambah atau hapus)
  Future<void> toggleFavorite(String recipeId, String userId) async {
    try {
      // Check if already favorited
      final existing = await _supabase
          .from('favorites')
          .select()
          .eq('recipe_id', recipeId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Remove favorite
        await _supabase
            .from('favorites')
            .delete()
            .eq('recipe_id', recipeId)
            .eq('user_id', userId);
      } else {
        // Add favorite
        await _supabase.from('favorites').insert({
          'recipe_id': recipeId,
          'user_id': userId,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 🔎 Cari resep berdasarkan judul
  Stream<List<Recipe>> searchByTitle(String query) {
    return _supabase
        .from('recipes_with_stats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) =>
                (json['title'] as String?)
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .map((json) => Recipe.fromMap(json))
            .toList());
  }

  /// 🧂 Cari resep berdasarkan bahan
  Stream<List<Recipe>> searchByIngredients(List<String> selectedIngredients) {
    return _supabase
        .from('recipes_with_stats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) {
              final ingredients = List<String>.from(json['ingredients'] ?? []);
              return selectedIngredients
                  .any((selected) => ingredients.contains(selected));
            })
            .map((json) => Recipe.fromMap(json))
            .toList());
  }

  /// 👩‍🍳 Ambil resep milik user tertentu
  Stream<List<Recipe>> getUserRecipes(String userId) {
    return _supabase
        .from('recipes_with_stats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) => json['user_id'] == userId)
            .map((json) => Recipe.fromMap(json))
            .toList());
  }

  /// 💕 Ambil resep yang difavoritkan user
  Stream<List<Recipe>> getUserFavorites(String userId) {
    return _supabase
        .from('recipes_with_stats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((recipes) async {
          // Get user's favorited recipe IDs
          final favorites = await _supabase
              .from('favorites')
              .select('recipe_id')
              .eq('user_id', userId);

          final favoriteIds = favorites.map((f) => f['recipe_id']).toList();

          // Filter recipes
          return recipes
              .where((recipe) => favoriteIds.contains(recipe['id']))
              .map((json) => Recipe.fromMap(json))
              .toList();
        });
  }

  /// 🔥 Ambil resep populer (urut berdasarkan rating_count)
  Stream<List<Recipe>> getPopularRecipes() {
    return _supabase
        .from('recipes_with_stats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          // Sort by rating_count in memory
          final list = data.toList();
          list.sort((a, b) {
            final countA = a['rating_count'] ?? 0;
            final countB = b['rating_count'] ?? 0;
            return (countB as int).compareTo(countA as int);
          });
          return list.take(20).map((json) => Recipe.fromMap(json)).toList();
        });
  }

  /// 📄 Ambil semua resep (untuk HomeScreen)
  Stream<List<Recipe>> getAllRecipes() {
    return _supabase
        .from('recipes_with_stats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Recipe.fromMap(json)).toList());
  }

  /// 👤 Update data profil user di Supabase
  Future<void> updateUserProfile(String userId,
      {String? displayName, String? photoUrl}) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (photoUrl != null) data['photo_url'] = photoUrl;
      data['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('users').update(data).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// 👤 Ambil profil user dari Supabase
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 👤 Create user profile (dipanggil saat sign up)
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      debugPrint('🔵 Creating user profile for: $userId, email: $email');
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'display_name': displayName ?? email.split('@')[0],
        'photo_url': photoUrl ?? '',
      });
      debugPrint('✅ User profile created successfully!');
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      rethrow;
    }
  }
}
