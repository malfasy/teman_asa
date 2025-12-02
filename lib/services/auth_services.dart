import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 1. Sign Up (Email & Password)
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveLoginStatus();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Lempar error spesifik agar bisa ditangkap UI
      throw Exception(_getFriendlyErrorMessage(e.code));
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  // 2. Sign In (Email & Password)
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveLoginStatus();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e.code));
    } catch (e) {
      throw Exception("Gagal Login: $e");
    }
  }

  // 3. Sign In (Google)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User batal login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _saveLoginStatus();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } on PlatformException catch (e) {
      throw Exception("Google Sign In Error: ${e.message}");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // 4. Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  // Helper pesan error bahasa Indonesia
  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email ini sudah terdaftar.';
      case 'invalid-email': return 'Format email salah.';
      case 'weak-password': return 'Password terlalu lemah.';
      case 'user-not-found': return 'Email tidak ditemukan.';
      case 'wrong-password': return 'Password salah.';
      case 'user-disabled': return 'Akun ini telah dinonaktifkan.';
      default: return 'Terjadi kesalahan ($code). Coba lagi.';
    }
  }
}