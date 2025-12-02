import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/initiation_screen.dart';
import 'package:teman_asa/screens/main_navigator.dart';
import 'package:teman_asa/screens/signup_screen.dart';
import 'package:teman_asa/services/auth_services.dart';
import 'package:teman_asa/theme.dart';

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
  bool _isObscure = true;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Email dan password wajib diisi");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Await di sini penting! Jika error, dia akan loncat ke catch
      await _authService.signInWithEmailAndPassword(email, password);
      
      // Jika baris ini tereksekusi, berarti login BERHASIL
      if (mounted) await _navigateBasedOnStatus();
      
    } catch (e) {
      // Menampilkan pesan error asli dari AuthService
      if (mounted) _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        await _navigateBasedOnStatus();
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateBasedOnStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isInit = prefs.getBool('isInitialized') ?? false;
    
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => isInit ? const MainNavigator() : const InitiationScreen()), 
      (route) => false
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
            Text("Welcome\nBack!", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: "Email Address", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure = !_isObscure)),
              ),
              obscureText: _isObscure,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: kMainTeal, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LOG IN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("OR LOG IN WITH", style: Theme.of(context).textTheme.bodySmall)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleLogin, 
                icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text("GOOGLE"),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account yet? "),
                GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())), child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: kMainTeal))),
              ],
            )
          ],
        ),
      ),
    );
  }
}