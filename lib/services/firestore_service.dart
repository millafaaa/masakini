import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Tambah resep baru ke Firestore
  Future<void> addRecipe(Recipe recipe) async {
    await _db.collection('recipes').doc(recipe.id).set(recipe.toMap());
  }

  /// 🗑️ Hapus resep berdasarkan ID
  Future<void> deleteRecipe(String id) async {
    await _db.collection('recipes').doc(id).delete();
  }

  /// ⭐ Tambahkan rating dan review baru
  Future<void> addRating(
    String recipeId,
    double rating,
    String review,
    String userId,
  ) async {
    final docRef = _db.collection('recipes').doc(recipeId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('Recipe not found');

      final data = snapshot.data()!;
      final ratings = List<double>.from(data['ratings'] ?? []);
      final reviews = List<String>.from(data['reviews'] ?? []);
      ratings.add(rating);
      reviews.add(review);

      transaction.update(docRef, {
        'ratings': ratings,
        'reviews': reviews,
      });
    });
  }

  /// 💗 Tambah atau hapus favorit (toggle)
  Future<void> toggleFavorite(String recipeId, String userId) async {
    final recipeRef = _db.collection('recipes').doc(recipeId);
    final recipeDoc = await recipeRef.get();

    if (!recipeDoc.exists) return;

    List<String> favorites = List<String>.from(recipeDoc['favorites'] ?? []);

    if (favorites.contains(userId)) {
      favorites.remove(userId);
    } else {
      favorites.add(userId);
    }

    await recipeRef.update({'favorites': favorites});
  }

  /// 🔎 Cari resep berdasarkan judul (dengan range query)
  Stream<List<Recipe>> searchByTitle(String query) {
    return _db
        .collection('recipes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// 🧂 Cari resep berdasarkan bahan (pakai array-contains-any)
  Stream<List<Recipe>> searchByIngredients(List<String> selectedIngredients) {
    return _db
        .collection('recipes')
        .where('ingredients', arrayContainsAny: selectedIngredients)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// 👩‍🍳 Ambil resep milik user tertentu
  Stream<List<Recipe>> getUserRecipes(String userId) {
    return _db
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// 💕 Ambil resep yang difavoritkan user
  Stream<List<Recipe>> getUserFavorites(String userId) {
    return _db
        .collection('recipes')
        .where('favorites', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// 🔥 Ambil resep populer (urut berdasarkan createdAt)
  Stream<List<Recipe>> getPopularRecipes() {
    return _db
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// 📄 Ambil semua resep (untuk HomeScreen)
  Stream<List<Recipe>> getAllRecipes() {
    return _db
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// 👤 Update data profil user di Firestore
  Future<void> updateUserProfile(String userId,
      {String? displayName, String? photoUrl}) async {
    final userRef = _db.collection('users').doc(userId);
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    await userRef.set(data, SetOptions(merge: true));
  }

  /// 👤 Ambil profil user dari Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }
}
