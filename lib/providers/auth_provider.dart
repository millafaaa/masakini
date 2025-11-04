import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  Map<String, dynamic>? _userProfile; // Custom Firestore profile data
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider(this._authService) {
    _initAuthListener();
  }

  /// ✅ Listen ke perubahan auth state (login/logout)
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      _isLoading = false;
      _error = null;

      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }

      notifyListeners();
    });
  }

  /// ✅ Ambil profil user dari Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _firestoreService.getUserProfile(userId);
      _userProfile = profile;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// ✅ Register user baru dengan email
  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUpWithEmail(email, password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Login user dengan email
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Login menggunakan Google
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Logout user
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Update display name (Auth + Firestore)
  Future<void> updateDisplayName(String name) async {
    if (_user == null || name == _user!.displayName) return;

    try {
      await _authService.updateDisplayName(name); // Update di Firebase Auth
      await _firestoreService.updateUserProfile(
        _user!.uid,
        displayName: name,
      ); // Update di Firestore
      await _loadUserProfile(_user!.uid); // Refresh data lokal
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// ✅ Bersihkan pesan error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Helper untuk ubah loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper untuk ubah error state
  void _setError(String value) {
    _error = value;
    notifyListeners();
  }
}
