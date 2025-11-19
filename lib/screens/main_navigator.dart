import 'package:flutter/material.dart';
import 'package:teman_asa/screens/aac_screen.dart';
import 'package:teman_asa/screens/content_screen.dart';
import 'package:teman_asa/screens/discover_screen.dart';
import 'package:teman_asa/screens/home_screen.dart';
import 'package:teman_asa/screens/train_screen.dart';
import 'package:teman_asa/theme.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _index = 0;
  final _screens = [
    const HomeScreen(),
    const AacScreen(),
    const ContentScreen(),
    const TrainScreen(),
    const DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            selectedItemColor: kMainTeal,
            unselectedItemColor: kIconGrey,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.record_voice_over_rounded), label: 'AAC'),
              BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Konten'),
              BottomNavigationBarItem(icon: Icon(Icons.track_changes_rounded), label: 'Latihan'),
              BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Discover'),
            ],
          ),
        ),
      ),
    );
  }
}