import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '', // Add this from Firebase/Google Cloud Console if needed
  );

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      print('🔵 Signing up user: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      print('✅ Sign up response - User: ${response.user?.id}, Session: ${response.session != null}');
      return response;
    } catch (e) {
      print('❌ Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      print('🔵 Signing in user: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ Sign in response - User: ${response.user?.id}, Session: ${response.session != null}');
      return response;
    } catch (e) {
      print('❌ Sign in error: $e');
      rethrow;
    }
  }

  /// Sign in with Google (Native)
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Sign out from previous session
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google (Web/Fallback using OAuth)
  Future<bool> signInWithGoogleOAuth() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.masakini://login-callback',
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Update display name in user metadata
  Future<UserResponse> updateDisplayName(String name) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(
          data: {'display_name': name},
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
