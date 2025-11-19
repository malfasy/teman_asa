import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/initiation_screen.dart';
import 'package:teman_asa/screens/main_navigator.dart';
import 'package:teman_asa/services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi email dan password")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      await _navigateBasedOnStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Gagal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    
    if (user != null && mounted) {
      await _navigateBasedOnStatus();
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateBasedOnStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Cek apakah user ini sudah pernah isi data inisiasi (data anak)
    bool isInit = prefs.getBool('isInitialized') ?? false;
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => isInit ? const MainNavigator() : const InitiationScreen()), 
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome\nBack!", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36)),
            const SizedBox(height: 32),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: "Email Address"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: "Password"), 
              obscureText: true
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("LOG IN"),
              ),
            ),
            
            const SizedBox(height: 20),
            Center(child: Text("OR LOG IN WITH", style: Theme.of(context).textTheme.titleSmall)),
            const SizedBox(height: 20),
             
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleLogin, 
                icon: const Icon(Icons.g_mobiledata, size: 30),
                label: const Text("GOOGLE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}