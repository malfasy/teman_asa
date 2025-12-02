import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/initiation_screen.dart';
import 'package:teman_asa/screens/login_screen.dart';
import 'package:teman_asa/screens/main_navigator.dart';
import 'package:teman_asa/services/auth_services.dart';
import 'package:teman_asa/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isPassObscure = true;
  bool _isConfirmObscure = true;

  void _handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Semua kolom wajib diisi");
      return;
    }
    if (password != confirm) {
      _showError("Password konfirmasi tidak sama");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmailAndPassword(email, password);
      
      // Reset status inisiasi karena ini user baru
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isInitialized', false);

      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const InitiationScreen()), (route) => false);
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        bool isInit = prefs.getBool('isInitialized') ?? false;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => isInit ? const MainNavigator() : const InitiationScreen()), (route) => false);
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create your\naccount", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(controller: _emailController, decoration: InputDecoration(hintText: "Email", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: _isPassObscure, decoration: InputDecoration(hintText: "Password", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: IconButton(icon: Icon(_isPassObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isPassObscure = !_isPassObscure)))),
            const SizedBox(height: 16),
            TextField(controller: _confirmController, obscureText: _isConfirmObscure, decoration: InputDecoration(hintText: "Confirm Password", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: IconButton(icon: Icon(_isConfirmObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isConfirmObscure = !_isConfirmObscure)))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _handleSignUp, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: kMainTeal, foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIGN UP", style: TextStyle(fontWeight: FontWeight.bold)))),
            const SizedBox(height: 20),
            Center(child: Text("OR SIGN UP WITH", style: Theme.of(context).textTheme.bodySmall)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _isLoading ? null : _handleGoogleSignUp, icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text("GOOGLE"), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            const SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Already have an account? "), GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold, color: kMainTeal)))]),
          ],
        ),
      ),
    );
  }
}