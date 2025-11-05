import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _databaseService = DatabaseService();

  User? _user;
  Map<String, dynamic>? _userProfile; // Custom Supabase profile data
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
    _authService.authStateChanges.listen((AuthState state) async {
      _user = state.session?.user;
      _isLoading = false;
      _error = null;

      if (_user != null) {
        await _loadUserProfile(_user!.id);
      } else {
        _userProfile = null;
      }

      notifyListeners();
    });
  }

  /// ✅ Ambil profil user dari Supabase
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _databaseService.getUserProfile(userId);
      if (profile != null) {
        _userProfile = profile;
      } else {
        // Profile doesn't exist yet, might be in creation process
        _userProfile = null;
      }
    } catch (e) {
      _error = 'Error loading profile: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// ✅ Register user baru dengan email
  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signUpWithEmail(email, password);
      if (response.user != null) {
        // Wait a bit for auth state to settle
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if profile already exists (race condition prevention)
        final existing = await _databaseService.getUserProfile(response.user!.id);
        if (existing == null) {
          // Create user profile in Supabase
          await _databaseService.createUserProfile(
            userId: response.user!.id,
            email: email,
            displayName: email.split('@')[0],
          );
          
          // Load the newly created profile
          await _loadUserProfile(response.user!.id);
        }
      } else if (response.session == null) {
        throw Exception('Pendaftaran gagal: Tidak ada session dibuat');
      }
    } catch (e) {
      _setError('Pendaftaran gagal: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Login user dengan email
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signInWithEmail(email, password);
      if (response.user == null || response.session == null) {
        throw Exception('Login gagal: Email atau password salah');
      }
    } catch (e) {
      _setError('Login gagal: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Login menggunakan Google
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signInWithGoogle();
      if (response?.user != null) {
        final user = response!.user!;
        
        // Wait a bit for auth state to settle
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if profile exists, if not create it
        final existing = await _databaseService.getUserProfile(user.id);
        if (existing == null) {
          await _databaseService.createUserProfile(
            userId: user.id,
            email: user.email ?? '',
            displayName: user.userMetadata?['full_name'] ??
                user.email?.split('@')[0] ??
                'User',
          );
          
          // Load the newly created profile
          await _loadUserProfile(user.id);
        }
      } else {
        throw Exception('Google Sign In dibatalkan');
      }
    } catch (e) {
      _setError('Google Sign In gagal: ${e.toString()}');
      rethrow;
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

  /// ✅ Update display name (Auth + Database)
  Future<void> updateDisplayName(String name) async {
    if (_user == null || name == (_userProfile?['display_name'] ?? '')) return;

    try {
      await _authService.updateDisplayName(name); // Update di Supabase Auth
      await _databaseService.updateUserProfile(
        _user!.id,
        displayName: name,
      ); // Update di Database
      await _loadUserProfile(_user!.id); // Refresh data lokal
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
