import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/state_widgets.dart';
import 'home_screen.dart';
import 'explore_barbers_screen.dart';
import '../booking/my_bookings_screen.dart';
import '../profile/client_profile_screen.dart';

class HomeNavShell extends StatefulWidget {
  const HomeNavShell({super.key});

  @override
  State<HomeNavShell> createState() => _HomeNavShellState();
}

class _HomeNavShellState extends State<HomeNavShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyBookingsScreen(),
    const ExploreBarbersScreen(),
    const ClientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut_outlined),
            activeIcon: Icon(Icons.content_cut),
            label: 'الحلاقين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
