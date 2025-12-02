import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // --- 1. Simulasi Sign Up (Tanpa Firebase) ---
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    // Simulasi loading network
    await Future.delayed(const Duration(seconds: 2));
    
    // Simpan status login
    await _saveLoginStatus(email);
    return true; // Selalu sukses
  }

  // --- 2. Simulasi Login (Tanpa Firebase) ---
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    await _saveLoginStatus(email);
    return true;
  }

  // --- 3. Simulasi Login Google (Tanpa Firebase) ---
  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 2));
    await _saveLoginStatus("google_user@example.com");
    return true;
  }

  // --- 4. Logout ---
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
  }

  // Helper: Simpan status login di HP
  Future<void> _saveLoginStatus(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
  }
}