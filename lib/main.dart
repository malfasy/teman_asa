import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // WAJIB IMPORT INI
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/welcome_screen.dart';
import 'package:teman_asa/screens/initiation_screen.dart';
import 'package:teman_asa/screens/main_navigator.dart';
import 'package:teman_asa/theme.dart';

void main() async {
  // 1. Pastikan Binding aktif
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Aktifkan Firebase (INI YANG MEMPERBAIKI ERROR ANDA)
  await Firebase.initializeApp(); 
  
  // 3. Cek status login
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool isInitialized = prefs.getBool('isInitialized') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn, isInitialized: isInitialized));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isInitialized;

  const MyApp({super.key, required this.isLoggedIn, required this.isInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TemanAsa',
      theme: temanAsaTheme(),
      debugShowCheckedModeBanner: false,
      home: !isLoggedIn 
          ? const WelcomeScreen() 
          : (!isInitialized ? const InitiationScreen() : const MainNavigator()),
    );
  }
}