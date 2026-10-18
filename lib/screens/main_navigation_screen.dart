import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home/home_screen.dart';
import 'plants/my_plants_screen.dart';
import 'identify/identify_screen.dart';
import 'reminders/reminders_screen.dart';
import 'profile/profile_screen.dart';

/// Navigation controller screen hosting the 5 primary tabs of Plant Care.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onNavigateToIdentify: () => _onTabTapped(2),
        onNavigateToMyPlants: () => _onTabTapped(1),
        onNavigateToReminders: () => _onTabTapped(3),
      ),
      const MyPlantsScreen(),
      const IdentifyScreen(),
      const RemindersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
