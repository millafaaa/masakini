import 'package:flutter/material.dart';
import 'package:masakini/screens/home_screen.dart';
import 'package:masakini/screens/search_screen.dart';
import 'package:masakini/screens/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  // List child screens (bisa expand jika tambah tab)
  final List<Widget> _screens = [
    const HomeScreen(),  // Tab 0: Home/Main Menu
    const SearchScreen(),  // Tab 1: Search by Bahan/Judul
    const ProfileScreen(),  // Tab 2: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,  // Preserve state: Screens tidak dispose saat switch
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}