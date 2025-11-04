import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload foto resep ke Firebase Storage
  Future<String> uploadRecipeImage(File imageFile, String userId) async {
    try {
      final ref = _storage
          .ref()
          .child('recipes/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final task = ref.putFile(imageFile, metadata);
      // Batasi waktu upload agar tidak menggantung terlalu lama
      await task.timeout(const Duration(seconds: 30));
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload foto profil user (path: profiles/{userId}.jpg)
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('profiles/$userId.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final task = ref.putFile(imageFile, metadata);
      await task.timeout(const Duration(seconds: 30));
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
