import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String description;
  final String image;
  final String category;
  final int cookingTime; // in minutes
  final int servings;
  final String difficulty; // easy, medium, hard
  final List<String> ingredients;
  final List<String> steps;
  final List<double> ratings;
  final List<String> reviews;
  final List<String> favorites;
  final Timestamp createdAt;

  Recipe({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userAvatar = '',
    required this.title,
    required this.description,
    required this.image,
    this.category = 'Lainnya',
    this.cookingTime = 30,
    this.servings = 2,
    this.difficulty = 'easy',
    required this.ingredients,
    required this.steps,
    required this.ratings,
    required this.reviews,
    required this.favorites,
    required this.createdAt,
  });

  /// 🔹 Hitung rata-rata rating
  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  /// 🔹 Cek apakah user sudah favorit
  bool isFavoritedBy(String userId) {
    return favorites.contains(userId);
  }

  /// 🔹 Konversi dari Firestore ke model
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      category: data['category'] ?? 'Lainnya',
      cookingTime: data['cookingTime'] ?? 30,
      servings: data['servings'] ?? 2,
      difficulty: data['difficulty'] ?? 'easy',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      ratings: List<double>.from(
        (data['ratings'] ?? []).map((r) => r is int ? r.toDouble() : r),
      ),
      reviews: List<String>.from(data['reviews'] ?? []),
      favorites: List<String>.from(data['favorites'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// 🔹 Konversi model ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
      'cookingTime': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'steps': steps,
      'ratings': ratings,
      'reviews': reviews,
      'favorites': favorites,
      'createdAt': createdAt,
    };
  }

  /// 🔹 Duplikasi model (berguna untuk update)
  Recipe copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? description,
    String? image,
    String? category,
    int? cookingTime,
    int? servings,
    String? difficulty,
    List<String>? ingredients,
    List<String>? steps,
    List<double>? ratings,
    List<String>? reviews,
    List<String>? favorites,
    Timestamp? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      ratings: ratings ?? this.ratings,
      reviews: reviews ?? this.reviews,
      favorites: favorites ?? this.favorites,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
