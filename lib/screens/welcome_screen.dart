import 'package:flutter/material.dart';
import 'package:teman_asa/screens/login_screen.dart';
import 'package:teman_asa/screens/signup_screen.dart';
import 'package:teman_asa/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo atau Ilustrasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: kMainTeal.withOpacity(0.2), blurRadius: 30)]
                ),
                child: const Icon(Icons.extension_rounded, size: 80, color: kAccentCoral),
              ),
              const SizedBox(height: 24),
              
              // Judul dengan Nerko One
              Text(
                "TemanAsa", 
                style: Theme.of(context).textTheme.displayLarge
              ),
              
              const SizedBox(height: 10),
              Text(
                "Kenali Dunianya,\nWujudkan Harapannya", 
                textAlign: TextAlign.center, 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: kMainTeal, fontSize: 24)
              ),
              
              const SizedBox(height: 16),
              Text(
                "Pendamping digital dalam perjalanan mengasuh anak dengan autisme.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const Spacer(),
              
              // Tombol dengan Poppins
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                  child: const Text("GET STARTED"),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Text("Log in", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMainTeal, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}