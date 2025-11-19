import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/main_navigator.dart';
import 'package:teman_asa/theme.dart';

class InitiationScreen extends StatefulWidget {
  const InitiationScreen({super.key});
  @override
  State<InitiationScreen> createState() => _InitiationScreenState();
}

class _InitiationScreenState extends State<InitiationScreen> {
  final PageController _controller = PageController();
  
  // Controller untuk mengambil teks input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childAgeController = TextEditingController();
  
  String _selectedRole = ""; 

  void _nextPage() {
    // Validasi halaman 1 (Nama)
    if (_controller.page?.round() == 0 && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi nama Anda dulu ya")));
      return;
    }
    // Validasi halaman 2 (Peran)
    if (_controller.page?.round() == 1 && _selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih peran Anda")));
      return;
    }
    
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    
    // SIMPAN SEMUA DATA KE MEMORI HP
    await prefs.setBool('isInitialized', true);
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userRole', _selectedRole);
    await prefs.setString('childName', _childNameController.text);
    await prefs.setString('childAge', _childAgeController.text);
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavigator()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () {
             if (_controller.page == 0) {
               Navigator.pop(context); 
             } else {
               _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
             }
          }
        )
      ),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), 
        children: [
          // Halaman 1: Nama
          _buildPage(
            "Welcome to\nTemanAsa", 
            "Siapa nama Anda?", 
            TextField(
              controller: _nameController, // Pasang controller
              decoration: const InputDecoration(hintText: "Nama Panggilan Anda"),
            ), 
            "NEXT", 
            _nextPage
          ),
          
          // Halaman 2: Peran
          _buildPage(
            "Who's Joining?", 
            "Hubungan dengan anak", 
            Column(
              children: [
                _option("Orang Tua"), 
                _option("Saudara"), 
                _option("Pengasuh"),
                _option("Terapis"),
              ]
            ), 
            "NEXT", 
            _nextPage
          ),
          
          // Halaman 3: Data Anak
          _buildPage(
            "Star of TemanAsa", 
            "Data Anak", 
            Column(
              children: [
                TextField(controller: _childNameController, decoration: const InputDecoration(hintText: "Nama Anak")), 
                const SizedBox(height: 10), 
                TextField(controller: _childAgeController, decoration: const InputDecoration(hintText: "Usia Anak (Tahun)")),
              ]
            ), 
            "NEXT", 
            _nextPage
          ),
          
          // Halaman 4: Selesai
          _buildPage(
            "Hooray!\nYou're all set!", 
            "Selamat bergabung!", 
            const Icon(Icons.check_circle, size: 100, color: kMainTeal), 
            "LET'S BEGIN", 
            _finish
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String title, String sub, Widget content, String btnText, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 12),
          Text(sub, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 40),
          content,
          const Spacer(),
          SizedBox(
            width: double.infinity, 
            child: ElevatedButton(onPressed: onAction, child: Text(btnText))
          ),
        ],
      ),
    );
  }

  Widget _option(String text) {
    bool isSelected = _selectedRole == text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedRole = text),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 55),
          backgroundColor: isSelected ? kMainTeal : Colors.transparent,
          side: BorderSide(color: isSelected ? kMainTeal : kIconGrey, width: 1.5),
          foregroundColor: isSelected ? Colors.white : kDarkGrey,
        ),
        child: Text(text, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontFamily: 'Poppins')),
      ),
    );
  }
}