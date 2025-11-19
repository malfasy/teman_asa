import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:teman_asa/theme.dart';

class AacScreen extends StatefulWidget {
  const AacScreen({super.key});

  @override
  State<AacScreen> createState() => _AacScreenState();
}

class _AacScreenState extends State<AacScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _customTextController = TextEditingController();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _customTextController.dispose();
    super.dispose();
  }

  void _initTts() async {
    // 1. Tunggu mesin suara siap
    await flutterTts.awaitSpeakCompletion(true);

    // 2. Cek apakah HP punya Bahasa Indonesia
    var isAvailable = await flutterTts.isLanguageAvailable("id-ID");

    if (isAvailable) {
      // 3. Jika ada, PAKSA pakai Indonesia
      await flutterTts.setLanguage("id-ID");
    } else {
      // 4. Jika tidak ada, beri peringatan ke pengguna
      if (mounted) {
        _showInstallDialog();
      }
    }

    // Pengaturan suara agar natural
    await flutterTts.setSpeechRate(0.5); 
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() => setState(() => isSpeaking = true));
    flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    flutterTts.setCancelHandler(() => setState(() => isSpeaking = false));
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      // Set ulang bahasa setiap kali mau bicara untuk memastikan
      await flutterTts.setLanguage("id-ID"); 
      await flutterTts.speak(text);
    }
  }

  void _showInstallDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Suara Indonesia Hilang"),
        content: const Text(
          "HP Anda belum memiliki data suara Bahasa Indonesia.\n\n"
          "Silakan buka: Pengaturan > Text-to-speech > Google Engine > Install Voice Data > Pilih 'Indonesian'."
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Oke"))
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Komunikasi (AAC)")),
      body: Column(
        children: [
          // INPUT MANUAL
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customTextController,
                    decoration: const InputDecoration(
                      hintText: "Ketik kata di sini...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 30, color: kMainTeal),
                  onPressed: () => _speak(_customTextController.text),
                ),
              ],
            ),
          ),

          // GRID TOMBOL
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(24),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _aacBtn("Makan", Icons.restaurant_menu_rounded, kMainTeal),
                _aacBtn("Minum", Icons.local_cafe_rounded, kMainTeal),
                _aacBtn("Sakit", Icons.sick, kAccentCoral),
                _aacBtn("Tidur", Icons.bedtime, kAccentPurple),
                _aacBtn("Main", Icons.toys, kAccentYellow),
                _aacBtn("Toilet", Icons.wc, kMainTeal),
                _aacBtn("Ya", Icons.check_circle, Colors.green),
                _aacBtn("Tidak", Icons.cancel, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aacBtn(String text, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _speak(text),
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFamily: 'NerkoOne')),
          ],
        ),
      ),
    );
  }
}