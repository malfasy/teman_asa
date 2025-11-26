import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/login_screen.dart';
import 'package:teman_asa/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "...";
  String role = "...";
  String childName = "...";
  String childAge = "...";
  String _selectedLanguage = "id-ID"; 

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "Pengguna";
      role = prefs.getString('userRole') ?? "Orang Tua";
      childName = prefs.getString('childName') ?? "-";
      childAge = prefs.getString('childAge') ?? "-";
      _selectedLanguage = prefs.getString('aac_language') ?? "id-ID";
    });
  }

  void _changeLanguage(String? newLang) async {
    if (newLang != null) {
      setState(() => _selectedLanguage = newLang);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aac_language', newLang);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bahasa diubah ke ${newLang == 'id-ID' ? 'Indonesia' : 'Inggris'}"))
        );
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Foto & Nama
              const CircleAvatar(radius: 50, backgroundColor: kMainTeal, child: Icon(Icons.person, size: 60, color: Colors.white)),
              const SizedBox(height: 16),
              Text(name, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              Text(role, style: const TextStyle(fontSize: 16, color: kIconGrey, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 32),
              
              // --- PENGATURAN BAHASA (LAYOUT DIPERBAIKI) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pengaturan Aplikasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kMainTeal)),
                    const Divider(height: 30),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text("Bahasa Suara", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: kSoftBeige,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            underline: Container(), // Hapus garis bawah default
                            icon: const Icon(Icons.arrow_drop_down, color: kMainTeal),
                            items: const [
                              DropdownMenuItem(value: "id-ID", child: Text("🇮🇩 Indonesia")),
                              DropdownMenuItem(value: "en-US", child: Text("🇺🇸 English")),
                            ], 
                            onChanged: _changeLanguage
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // Info Anak
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Data Anak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kMainTeal)),
                    const Divider(height: 30),
                    _infoRow("Nama", childName),
                    _infoRow("Usia", "$childAge Tahun"),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: kAccentCoral),
                  label: const Text("KELUAR", style: TextStyle(color: kAccentCoral)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: kAccentCoral)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kIconGrey)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis, 
            ),
          ),
        ],
      ),
    );
  }
}