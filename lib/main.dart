import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Connect to Firebase Emulator (untuk development tanpa billing)
  if (kDebugMode) {
    // Pilih host sesuai platform:
    // - Android emulator: 10.0.2.2 (alias ke localhost PC)
    // - Web/Windows/macOS/Linux: localhost
    final host = kIsWeb
        ? 'localhost'
        : (defaultTargetPlatform == TargetPlatform.android
            ? '10.0.2.2'
            : 'localhost');
    
    try {
      // Connect Authentication Emulator
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      
      // Connect Firestore Emulator
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8081);
      
      // Connect Storage Emulator
      await FirebaseStorage.instance.useStorageEmulator(host, 9199);
      
      debugPrint('🔥 Firebase Emulators Connected!');
      debugPrint('📍 Auth: http://$host:9099');
      debugPrint('📍 Firestore: http://$host:8081');
      debugPrint('📍 Storage: http://$host:9199');
      debugPrint('📍 Emulator UI: http://localhost:4000');
    } catch (e) {
      debugPrint('⚠️ Error connecting to emulators: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthService()),
      child: MaterialApp(
        title: 'MasakIni',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Primary Colors
          primaryColor: const Color(0xFFFF6B9D), // Pink
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B9D),
            secondary: const Color(0xFFFF9A56), // Orange
            brightness: Brightness.light,
          ),
          
          // AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF6B9D),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Card Theme
          cardTheme: const CardThemeData(
            elevation: 3,
          ),
          
          // Button Themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFF9A56),
            foregroundColor: Colors.white,
          ),
          
          // Input Theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
            ),
          ),
          
          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFFFF6B9D),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          
          // Icon Theme
          iconTheme: const IconThemeData(
            color: Color(0xFFFF6B9D),
          ),
          
          // Text Theme
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
            ),
          ),
          
          useMaterial3: true,
        ),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('id'),
        home: const SplashScreen(),
      ),
    );
  }
}

// Removed: AuthWrapper is now handled by SplashScreen
