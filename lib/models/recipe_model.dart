class Recipe {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String description;
  final String image;
  final String category;
  final String cuisineType; // Indonesian, Western, Chinese, etc
  final int cookingTime; // in minutes
  final int servings;
  final String difficulty; // easy, medium, hard
  final List<String> ingredients;
  final List<String> steps;
  final List<double> ratings;
  final List<String> reviews;
  final List<String> favorites;
  final DateTime createdAt;

  // Default placeholder image
  static const String defaultImage = 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=800&q=80';

  Recipe({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userAvatar = '',
    required this.title,
    required this.description,
    required this.image,
    this.category = 'Lainnya',
    this.cuisineType = 'Indonesian',
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

  /// 🔹 Get image URL with default fallback
  String get imageUrl => image.isNotEmpty ? image : defaultImage;

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

  /// 🔹 Konversi dari Supabase Map ke model
  factory Recipe.fromMap(Map<String, dynamic> data) {
    return Recipe(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      userAvatar: data['user_avatar'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      image: data['image'] ?? data['image_url'] ?? '',
      category: data['category'] ?? 'Lainnya',
      cuisineType: data['cuisine_type'] ?? 'Indonesian',
      cookingTime: data['cooking_time'] ?? 30,
      servings: data['servings'] ?? 2,
      difficulty: data['difficulty'] ?? 'easy',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      ratings: List<double>.from(
        (data['ratings'] ?? []).map((r) => r is int ? r.toDouble() : r),
      ),
      reviews: List<String>.from(data['reviews'] ?? []),
      favorites: List<String>.from(data['favorites'] ?? []),
      createdAt: data['created_at'] is String
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }

  /// 🔹 Konversi model ke Map untuk disimpan di Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'title': title,
      'description': description,
      'image_url': image,
      'category': category,
      'cuisine_type': cuisineType,
      'cooking_time': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'steps': steps,
      'ratings': ratings,
      'reviews': reviews,
      'favorites': favorites,
      'created_at': createdAt.toIso8601String(),
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
    String? cuisineType,
    int? cookingTime,
    int? servings,
    String? difficulty,
    List<String>? ingredients,
    List<String>? steps,
    List<double>? ratings,
    List<String>? reviews,
    List<String>? favorites,
    DateTime? createdAt,
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
      cuisineType: cuisineType ?? this.cuisineType,
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
