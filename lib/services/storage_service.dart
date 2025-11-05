import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload foto resep ke Supabase Storage
  Future<String> uploadRecipeImage(File imageFile, String userId) async {
    try {
      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await imageFile.readAsBytes();

      await _supabase.storage.from('recipes').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      return _supabase.storage.from('recipes').getPublicUrl(fileName);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload foto profil user (path: profiles/{userId}.jpg)
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final fileName = '$userId.jpg';
      final bytes = await imageFile.readAsBytes();

      await _supabase.storage.from('profiles').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // Replace existing photo
            ),
          );

      return _supabase.storage.from('profiles').getPublicUrl(fileName);
    } catch (e) {
      rethrow;
    }
  }
}
