import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/lessons/screens/lessons_list_screen.dart';
import 'package:kisolo/users/screens/onboarding_screen.dart';
import 'package:kisolo/users/screens/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OnboardingScreen(),
    const LessonsListScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Ndaku',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Mateya',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlack.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
          items: _navItems,
        ),
      ),
    );
  }
}
