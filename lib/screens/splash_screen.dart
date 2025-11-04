import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masakini/providers/auth_provider.dart';
import 'main_navigation.dart';
import 'auth/auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Jika belum selesai loading, tampilkan splash
        if (authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/app_icon.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, __, ___) => Icon(
                      Icons.restaurant,
                      size: 120,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'MasakIni 🍳',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Setelah loading selesai, check apakah user login
        if (authProvider.isAuthenticated) {
          return const MainNavigation();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
