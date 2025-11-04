import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masakini/models/recipe_model.dart';
import 'package:masakini/services/firestore_service.dart';

class DetailRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const DetailRecipeScreen({super.key, required this.recipe});

  @override
  State<DetailRecipeScreen> createState() => _DetailRecipeScreenState();
}

class _DetailRecipeScreenState extends State<DetailRecipeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;
  double _rating = 0;
  final _reviewController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isFavorite = recipe.isFavoritedBy(user?.uid ?? '');

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink.shade200,
        title: Text(
          recipe.title,
          style: const TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: () async {
              if (user != null) {
                await _firestoreService.toggleFavorite(recipe.id, user!.uid);
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🌷 Gambar Resep
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                recipe.image.isNotEmpty
                    ? recipe.image
                    : 'https://via.placeholder.com/400x250.png?text=Masakini+Recipe',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // 🍰 Judul & Deskripsi
            Text(
              recipe.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay',
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              recipe.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.pink.shade100),

            // 🌿 Bahan-bahan
            _buildSectionTitle("🌸 Bahan-bahan"),
            for (var item in recipe.ingredients)
              ListTile(
                leading: const Icon(Icons.circle, size: 8, color: Colors.pinkAccent),
                title: Text(item, style: const TextStyle(fontSize: 15)),
              ),

            const SizedBox(height: 16),
            _buildSectionTitle("🍓 Langkah Memasak"),
            for (int i = 0; i < recipe.steps.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pink.shade100,
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.pinkAccent)),
                ),
                title: Text(recipe.steps[i]),
              ),

            const SizedBox(height: 20),
            Divider(color: Colors.pink.shade100),

            // 🌼 Rating & Review Section
            _buildSectionTitle("💖 Beri Penilaian"),
            const SizedBox(height: 8),
            _buildRatingStars(),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: "Tulis review kamu (opsional)...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.pink.shade100),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.send, color: Colors.white),
              label: _loading
                  ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Kirim", style: TextStyle(color: Colors.white)),
              onPressed: _loading ? null : _submitRating,
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("🧁 Review dari Pengguna"),
            const SizedBox(height: 8),

            // Menampilkan review dari Firestore
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('recipes').doc(recipe.id).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final reviews = List<String>.from(data?['reviews'] ?? []);
                final ratings = List<double>.from(
                  (data?['ratings'] ?? []).map((r) => r is int ? r.toDouble() : r),
                );

                if (reviews.isEmpty) {
                  return const Text(
                    "Belum ada review 😋",
                    style: TextStyle(color: Colors.black54),
                  );
                }

                return Column(
                  children: List.generate(reviews.length, (index) {
                    final ratingValue = ratings[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Icon(Icons.favorite, color: Colors.pink.shade300),
                        title: Text(reviews[index]),
                        subtitle: Text("Rating: ${ratingValue.toStringAsFixed(1)} ⭐"),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
          fontFamily: 'PlayfairDisplay',
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(
            i < _rating ? Icons.star : Icons.star_border,
            color: Colors.pinkAccent,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _rating = (i + 1).toDouble();
            });
          },
        );
      }),
    );
  }

  Future<void> _submitRating() async {
    if (user == null || _rating == 0) return;
    setState(() => _loading = true);
    try {
      await _firestoreService.addRating(
        widget.recipe.id,
        _rating,
        _reviewController.text.trim(),
        user!.uid,
      );
      _reviewController.clear();
      _rating = 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review berhasil dikirim 💕")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal kirim review: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
